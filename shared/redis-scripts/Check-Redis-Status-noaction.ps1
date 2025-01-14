# Variables
$ServiceName = "Redis"
$RedisPort = 6379
$RedisHost = "127.0.0.1"

# Check if Redis service is running
Write-Host "Checking Redis service status..."
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($null -eq $service) {
    Write-Host "Redis service '$ServiceName' is not installed." -ForegroundColor Red
    exit 1
}

if ($service.Status -eq "Running") {
    Write-Host "Redis service '$ServiceName' is running." -ForegroundColor Green
} else {
    Write-Host "Redis service '$ServiceName' is not running. Status: $($service.Status)" -ForegroundColor Yellow
    exit 1
}

# Check if the Redis port is open
Write-Host "Checking if Redis is listening on port $RedisPort..."
try {
    $tcpConnection = Test-NetConnection -ComputerName $RedisHost -Port $RedisPort
    if ($tcpConnection.TcpTestSucceeded) {
        Write-Host "Redis is listening on ${RedisHost}:${RedisPort}." -ForegroundColor Green
    } else {
        Write-Host "Redis is not listening on ${RedisHost}:${RedisPort}." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error checking Redis port: $_" -ForegroundColor Red
    exit 1
}

# Optional: Perform a PING command to Redis
Write-Host "Pinging Redis to verify connectivity..."
try {
    $connection = New-Object System.Net.Sockets.TcpClient($RedisHost, $RedisPort)
    $stream = $connection.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $reader = New-Object System.IO.StreamReader($stream)

    # Send PING command
    $writer.WriteLine("PING")
    $writer.Flush()

    # Read response
    $response = $reader.ReadLine()
    if ($response -eq "+PONG") {
        Write-Host "Redis responded with PONG. Connectivity is confirmed!" -ForegroundColor Green
    } else {
        Write-Host "Unexpected response from Redis: $response" -ForegroundColor Yellow
    }

    # Close connection
    $writer.Close()
    $reader.Close()
    $connection.Close()
} catch {
    Write-Host "Error communicating with Redis: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Redis is running and accessible!"