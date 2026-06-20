@echo off
setlocal EnableExtensions
cd /d "%~dp0\.."

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0repair-windows-rocksdb-cstdint.ps1"
if errorlevel 1 exit /b %errorlevel%

echo.
echo Next commands:
echo   cargo clean -p librocksdb-sys
echo   cargo check
endlocal
