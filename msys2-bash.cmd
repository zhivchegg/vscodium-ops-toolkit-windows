@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
set "MSYS2_ROOT=%SCRIPT_DIR%msys64"
set "MSYSTEM=MSYS"
set "CHERE_INVOKING=1"
"%MSYS2_ROOT%\usr\bin\bash.exe" -li %*
