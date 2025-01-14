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