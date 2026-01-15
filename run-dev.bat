@echo off
REM Development startup script for Chat Control Preparation
REM This batch file starts both the backend API and frontend Flutter app

echo Starting development environment...
echo.

REM Get the script directory (project root)
set SCRIPT_DIR=%~dp0
set BACKEND_DIR=%SCRIPT_DIR%backend\CCP.Api
set FRONTEND_DIR=%SCRIPT_DIR%frontend

REM Check if directories exist
if not exist "%BACKEND_DIR%" (
    echo Error: Backend directory not found at %BACKEND_DIR%
    exit /b 1
)

if not exist "%FRONTEND_DIR%" (
    echo Error: Frontend directory not found at %FRONTEND_DIR%
    exit /b 1
)

REM Start backend in a new window
echo Starting backend API...
start "Backend API" powershell -NoExit -Command "cd '%BACKEND_DIR%'; dotnet run"

REM Wait a few seconds for the backend to start
echo Waiting for backend to initialize...
timeout /t 3 /nobreak >nul

REM Start Flutter app with Chrome as the default device
echo Starting Flutter app in Chrome...
echo.
cd /d "%FRONTEND_DIR%"
flutter run -d chrome
