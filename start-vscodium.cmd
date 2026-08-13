@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
set "MSYS2_BIN=%SCRIPT_DIR%msys64\usr\bin"
set "MINGW_BIN=%SCRIPT_DIR%msys64\mingw64\bin"
set "PATH=%MSYS2_BIN%;%MINGW_BIN%;%PATH%"
set "MSYSTEM=MSYS"
set "CHERE_INVOKING=1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%setup-home.ps1" >nul 2>&1
start "" "%SCRIPT_DIR%VSCodium.exe" %*
