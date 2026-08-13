@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PS_FILE=%SCRIPT_DIR%configure-runtime.ps1"

if not exist "%PS_FILE%" (
    echo ERROR: configure-runtime.ps1 not found in %SCRIPT_DIR%
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%setup-home.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_FILE%"
