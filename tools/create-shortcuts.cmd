@echo off
setlocal

:: Detect the directory where this script is located
set "BUNDLE_DIR=%~dp0"
if "%BUNDLE_DIR:~-1%"=="\" set "BUNDLE_DIR=%BUNDLE_DIR:~0,-1%"

:: Run PowerShell GUI for shortcut setup
powershell -NoProfile -ExecutionPolicy Bypass -File "%BUNDLE_DIR%\create-shortcuts.ps1"

endlocal
