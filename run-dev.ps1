# Development startup script for Chat Control Preparation
# This script starts both the backend API and frontend Flutter app

Write-Host "Starting development environment..." -ForegroundColor Green
Write-Host ""

# Get the script directory (project root)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendPath = Join-Path $scriptPath "backend\CCP.Api"
$frontendPath = Join-Path $scriptPath "frontend"

# Check if directories exist
if (-not (Test-Path $backendPath)) {
    Write-Host "Error: Backend directory not found at $backendPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $frontendPath)) {
    Write-Host "Error: Frontend directory not found at $frontendPath" -ForegroundColor Red
    exit 1
}

# Start backend in a new PowerShell window
Write-Host "Starting backend API..." -ForegroundColor Yellow
$backendScript = "cd '$backendPath'; dotnet run"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendScript

# Wait a few seconds for the backend to start
Write-Host "Waiting for backend to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Start Flutter app with Chrome as the default device
Write-Host "Starting Flutter app in Chrome..." -ForegroundColor Yellow
Write-Host ""
Set-Location $frontendPath
flutter run -d chrome
