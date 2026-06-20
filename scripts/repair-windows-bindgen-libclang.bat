@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0repair-windows-bindgen-libclang.ps1"
exit /b %ERRORLEVEL%
