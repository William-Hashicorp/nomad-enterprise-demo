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

# Start the Redis Service
Start-Sleep -Seconds 5
Stop-Service -Name $ServiceName
Start-Sleep -Seconds 5
Start-Service -Name $ServiceName
Start-Sleep -Seconds 5

# Confirm Service Status
Write-Host "Redis Service Status:"
Get-Service -Name $ServiceName | Format-Table -AutoSize