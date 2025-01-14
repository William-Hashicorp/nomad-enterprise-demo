# Variables
$ServiceName = "Redis"
$RedisInstaller = "C:\Temp\Redis-x64-5.0.14.1.msi" # Path to the original Redis MSI file
$InstallPath = "C:\Program Files\Redis"

# Stop the Redis Service
Write-Host "Stopping Redis service if running..."
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($null -ne $service -and $service.Status -eq "Running") {
    Stop-Service -Name $ServiceName -Force
    Write-Host "Redis service stopped." -ForegroundColor Green
} elseif ($null -ne $service) {
    Write-Host "Redis service is already stopped." -ForegroundColor Yellow
} else {
    Write-Host "Redis service does not exist." -ForegroundColor Red
}

# Remove the Redis Service
Write-Host "Removing Redis service..."
if ($null -ne $service) {
    & "$InstallPath\redis-server.exe" --service-uninstall
    Write-Host "Redis service removed." -ForegroundColor Green
} else {
    Write-Host "Redis service was not found. Skipping service removal." -ForegroundColor Yellow
}

# Uninstall Redis
Write-Host "Uninstalling Redis..."
if (Test-Path $RedisInstaller) {
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x `"$RedisInstaller`" /quiet /norestart" -Wait
    Write-Host "Redis uninstalled successfully." -ForegroundColor Green
} else {
    Write-Host "Redis installer not found at $RedisInstaller. Skipping uninstallation." -ForegroundColor Yellow
}

# Remove Redis Files and Directories
Write-Host "Deleting Redis installation directory..."
if (Test-Path $InstallPath) {
    Remove-Item -Path $InstallPath -Recurse -Force
    Write-Host "Redis installation directory deleted." -ForegroundColor Green
} else {
    Write-Host "Redis installation directory not found. Skipping cleanup." -ForegroundColor Yellow
}

# Confirm Cleanup
Write-Host "Cleanup process complete!"