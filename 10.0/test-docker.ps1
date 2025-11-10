#!/usr/bin/env pwsh

#########################################
# webPDF Docker Test Script (PowerShell)
# Tests the built Docker image
# Compatible with Windows, Linux, macOS
#########################################

# Configuration
$IMAGE_NAME = "softvisiondev/webpdf:10.0.3"
$CONTAINER_NAME = "webpdf-test"
$PORT = "8080"
$HEALTHCHECK_TIMEOUT = 120  # seconds
$LOCAL_PACKAGE = "true"  # Use local package (./packages/webpdf.deb)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "webPDF Docker Test Suite (PowerShell)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Function to print status
function Print-Status {
    param(
        [bool]$Success,
        [string]$Message
    )

    if ($Success) {
        Write-Host "✓ " -ForegroundColor Green -NoNewline
        Write-Host $Message
    } else {
        Write-Host "✗ " -ForegroundColor Red -NoNewline
        Write-Host $Message
        exit 1
    }
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

# Cleanup function
function Cleanup {
    Print-Info "Cleaning up..."
    docker stop $CONTAINER_NAME 2>$null | Out-Null
    docker rm $CONTAINER_NAME 2>$null | Out-Null
}

# Register cleanup on exit
trap {
    Cleanup
    break
}

# Test 1: Build the image
Print-Info "Test 1: Building Docker image (LOCAL_PACKAGE=$LOCAL_PACKAGE)..."
$buildOutput = docker build --build-arg LOCAL_PACKAGE=$LOCAL_PACKAGE -t $IMAGE_NAME . 2>&1
if ($LASTEXITCODE -eq 0) {
    Print-Status -Success $true -Message "Image built successfully"
} else {
    Write-Host "Build output (last 30 lines):" -ForegroundColor Red
    Write-Host "---"
    $buildOutput | Select-Object -Last 30
    Write-Host "---"
    Print-Status -Success $false -Message "Image build failed (exit code: $LASTEXITCODE)"
}

# Test 2: Check image size
Print-Info "Test 2: Checking image size..."
$IMAGE_SIZE = docker images $IMAGE_NAME --format "{{.Size}}"
Write-Host "   Image size: $IMAGE_SIZE"
Print-Status -Success $true -Message "Image size reported"

# Test 3: Start container
Print-Info "Test 3: Starting container..."
try {
    docker run -d --name $CONTAINER_NAME -p "${PORT}:${PORT}" $IMAGE_NAME | Out-Null
    Start-Sleep -Seconds 5
    Print-Status -Success $true -Message "Container started"
} catch {
    Print-Status -Success $false -Message "Container start failed"
}

# Test 4: Check if container is running
Print-Info "Test 4: Checking container status..."
$CONTAINER_STATUS = docker inspect -f '{{.State.Running}}' $CONTAINER_NAME
if ($CONTAINER_STATUS -eq "true") {
    Print-Status -Success $true -Message "Container is running"
} else {
    Print-Status -Success $false -Message "Container is not running"
}

# Test 5: Check healthcheck status
Print-Info "Test 5: Waiting for healthcheck (max ${HEALTHCHECK_TIMEOUT}s)..."
$ELAPSED = 0
$INTERVAL = 10
$HEALTHY = $false

while ($ELAPSED -lt $HEALTHCHECK_TIMEOUT) {
    try {
        $HEALTH_STATUS = docker inspect -f '{{.State.Health.Status}}' $CONTAINER_NAME 2>$null
    } catch {
        $HEALTH_STATUS = "none"
    }

    if ($HEALTH_STATUS -eq "healthy") {
        Print-Status -Success $true -Message "Container is healthy"
        $HEALTHY = $true
        break
    } elseif ($HEALTH_STATUS -eq "unhealthy") {
        Write-Host "   Last health check output:"
        docker inspect -f '{{range .State.Health.Log}}{{.Output}}{{end}}' $CONTAINER_NAME
        Print-Status -Success $false -Message "Container is unhealthy"
    }

    Write-Host "   Health status: $HEALTH_STATUS (${ELAPSED}s elapsed)"
    Start-Sleep -Seconds $INTERVAL
    $ELAPSED += $INTERVAL
}

if (-not $HEALTHY) {
    Print-Status -Success $false -Message "Healthcheck timeout - container did not become healthy"
}

# Test 6: Check webPDF endpoint directly
Print-Info "Test 6: Testing /webPDF/health endpoint..."
Start-Sleep -Seconds 2
try {
    $response = Invoke-WebRequest -Uri "http://localhost:${PORT}/webPDF/health" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Print-Status -Success $true -Message "Health endpoint returns HTTP 200"
    } else {
        Write-Host "   HTTP Status: $($response.StatusCode)"
        Print-Status -Success $false -Message "Health endpoint failed"
    }
} catch {
    Write-Host "   Error: $_"
    Print-Status -Success $false -Message "Health endpoint failed"
}

# Test 7: Check if fonts are installed
Print-Info "Test 7: Verifying font installation..."
$FONT_OUTPUT = docker exec $CONTAINER_NAME fc-list 2>$null
$FONT_COUNT = ($FONT_OUTPUT | Measure-Object -Line).Lines
Write-Host "   Fonts installed: $FONT_COUNT"
if ($FONT_COUNT -gt 50) {
    Print-Status -Success $true -Message "Fonts installed successfully ($FONT_COUNT fonts)"
} else {
    Print-Status -Success $false -Message "Insufficient fonts installed"
}

# Test 8: Check specific fonts (MS Core, Noto, Custom)
Print-Info "Test 8: Checking specific font families..."
$FONTS_TO_CHECK = @("Arial", "Calibri", "Tahoma", "Noto", "Liberation")
foreach ($FONT in $FONTS_TO_CHECK) {
    if ($FONT_OUTPUT -match $FONT) {
        Write-Host "   ✓ " -ForegroundColor Green -NoNewline
        Write-Host "$FONT found"
    } else {
        Write-Host "   ⚠ " -ForegroundColor Yellow -NoNewline
        Write-Host "$FONT not found (may be optional)"
    }
}

# Test 9: Check webPDF user and permissions
Print-Info "Test 9: Checking user and permissions..."
$CURRENT_USER = docker exec $CONTAINER_NAME whoami 2>$null
if ($CURRENT_USER -eq "webpdf") {
    Print-Status -Success $true -Message "Running as non-root user (webpdf)"
} else {
    Print-Status -Success $false -Message "Not running as expected user"
}

# Test 10: Check webPDF installation path
Print-Info "Test 10: Checking webPDF installation..."
$FILE_EXISTS = docker exec $CONTAINER_NAME test -f /opt/webpdf/webpdf.starter.sh 2>$null
if ($LASTEXITCODE -eq 0) {
    Print-Status -Success $true -Message "webPDF installation verified"
} else {
    Print-Status -Success $false -Message "webPDF installation not found"
}

# Test 11: Show container logs (last 20 lines)
Print-Info "Container logs (last 20 lines):"
Write-Host "---"
docker logs --tail 20 $CONTAINER_NAME 2>&1
Write-Host "---"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "All tests passed!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Container Information:"
Write-Host "  Name: $CONTAINER_NAME"
Write-Host "  Image: $IMAGE_NAME"
Write-Host "  Port: http://localhost:$PORT"
Write-Host ""
Write-Host "To stop and remove the container:"
Write-Host "  docker stop $CONTAINER_NAME" -ForegroundColor Cyan
Write-Host "  docker rm $CONTAINER_NAME" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to cleanup and exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Final cleanup
Cleanup
