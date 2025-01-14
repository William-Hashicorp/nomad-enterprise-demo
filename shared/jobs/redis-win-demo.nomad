job "redis-demo-service" {
  datacenters = ["dc1"]
  region      = "region1"

  # Constraint to ensure it runs only on Windows servers
  constraint {
    attribute = "${attr.kernel.name}"
    operator  = "="
    value     = "windows"
  }

  group "redis-group" {
    count = 1

    network {
      port "db" {
        static = 6379 # Bind Redis to port 6379
      }
    }

    service {
      provider = "nomad"
      name     = "redis"
      port     = "db"
      check {
        name         = "redis_probe"
        type         = "tcp"
        interval     = "10s"
        timeout      = "1s"
        address_mode = "host" # Ensure Nomad checks the host's network
      }
    }

    # Task: Install Redis Service
    task "install-redis" {
      lifecycle {
        hook = "prestart"
      }

      driver = "raw_exec"
      
      config {
        command = "powershell.exe"
        args    = ["-File", "${NOMAD_TASK_DIR}\\install-redis.ps1"]
      }

      template {
        destination = "${NOMAD_TASK_DIR}\\install-redis.ps1"
        data = <<EOF
# Install Redis
$RedisUrl = "https://github.com/tporadowski/redis/releases/download/v5.0.14.1/Redis-x64-5.0.14.1.msi"
$RedisInstaller = "C:\\Temp\\Redis-x64-5.0.14.1.msi"
$InstallPath = "C:\\Program Files\\Redis"
$ServiceName = "Redis"
$RedisConf = "$InstallPath\\redis.windows-service.conf"

# Create necessary directories
Write-Host "Creating necessary directories..."
New-Item -ItemType Directory -Force -Path (Split-Path $RedisInstaller)

# Download Redis MSI
Write-Host "Downloading Redis MSI..."
Invoke-WebRequest -Uri $RedisUrl -OutFile $RedisInstaller

# Install Redis
Write-Host "Installing Redis..."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$RedisInstaller`" /quiet /norestart INSTALLLOCATION=`"$InstallPath`"" -Wait

# Modify the existing configuration file
Write-Host "Modifying redis.windows-service.conf..."
(Get-Content -Path $RedisConf) -replace "bind 127.0.0.1", "bind 0.0.0.0" -replace "protected-mode yes", "protected-mode no" | Set-Content -Path $RedisConf

Start-Sleep -Seconds 5

# Uninstall the existing Redis service (if installed)
& "$InstallPath\\redis-server.exe" --service-uninstall -ErrorAction SilentlyContinue

# Install Redis as a Windows Service with the modified config file
& "$InstallPath\\redis-server.exe" --service-install "$RedisConf" --service-name $ServiceName

# Restart the Redis Service so that it start to listen on the IP address.
Start-Sleep -Seconds 5
Stop-Service -Name $ServiceName
Start-Sleep -Seconds 5
Start-Service -Name $ServiceName
Start-Sleep -Seconds 5

# Confirm Service Status
Write-Host "Redis Service Status:"
Get-Service -Name $ServiceName | Format-Table -AutoSize
EOF
      }
    }

    # Task: Monitor Redis Service (Continuous Monitoring)
    task "monitor-redis" {
      driver = "raw_exec"

      config {
        command = "powershell.exe"
        args    = ["-File", "${NOMAD_TASK_DIR}\\check-redis-status.ps1"]
      }

      template {
        destination = "${NOMAD_TASK_DIR}\\check-redis-status.ps1"
        data = <<EOF
# Variables
$ServiceName = "Redis"

# Continuous Monitoring Loop
while ($true) {
    # Get current date and time
    $currentTime = Get-Date -Format "HH:mm:ss on MMM dd, yyyy"

    # Check Redis service status
    Write-Host "Checking Redis service status at $currentTime..."
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

    if ($null -eq $service) {
        Write-Host "Redis service '$ServiceName' is not installed at $currentTime." -ForegroundColor Red
    } elseif ($service.Status -eq "Running") {
        Write-Host "Redis service '$ServiceName' is running at $currentTime." -ForegroundColor Green
    } else {
        Write-Host "Redis service '$ServiceName' is not running at $currentTime. Attempting to restart..." -ForegroundColor Yellow
        Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 30
        $currentTime = Get-Date -Format "HH:mm:ss on MMM dd, yyyy"
        Write-Host "Restart attempt completed at $currentTime." -ForegroundColor Green
    }

    # Sleep before next check
    Start-Sleep -Seconds 30
}
EOF
      }
    }

    # Task: Cleanup Redis Service
    task "cleanup-redis" {
      lifecycle {
        hook = "poststop"
      }

      driver = "raw_exec"
      
      config {
        command = "powershell.exe"
        args    = ["-File", "${NOMAD_TASK_DIR}\\cleanup-redis.ps1"]
      }

      template {
        destination = "${NOMAD_TASK_DIR}\\cleanup-redis.ps1"
        data = <<EOF
# Cleanup Redis
$ServiceName = "Redis"
$RedisInstaller = "C:\\Temp\\Redis-x64-5.0.14.1.msi"
$InstallPath = "C:\\Program Files\\Redis"

# Stop Redis service if running
Write-Host "Stopping Redis service..."
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($null -ne $service -and $service.Status -eq "Running") {
    Stop-Service -Name $ServiceName -Force
    Write-Host "Redis service stopped."
}

# Uninstall Redis service
Write-Host "Uninstalling Redis service..."
if ($null -ne $service) {
    & "$InstallPath\\redis-server.exe" --service-uninstall
}

# Uninstall Redis
if (Test-Path $RedisInstaller) {
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x `"$RedisInstaller`" /quiet /norestart" -Wait
}

# Remove Redis files
if (Test-Path $InstallPath) {
    Remove-Item -Path $InstallPath -Recurse -Force
    Write-Host "Redis installation directory removed."
}
EOF
      }
    }
  }
}