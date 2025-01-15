# hello-world.ps1
$logFile = "C:\temp\hello-world.txt"
Write-Host "Starting Hello World script..."
while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - Hello, World!"
    Start-Sleep -Seconds 10
}