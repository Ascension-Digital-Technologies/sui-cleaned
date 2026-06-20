@echo off
setlocal EnableExtensions
cd /d "%~dp0\.."

set "MODE=%~1"
if "%MODE%"=="" set "MODE=fast"

if /I "%MODE%"=="fast" (
  cargo xtask check-fast
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="core" (
  cargo xtask check-core
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="workspace" (
  cargo xtask check-workspace
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="compat" (
  cargo xtask check-sui-compat
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="full" (
  cargo xtask check-full
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="windows" (
  call scripts\repair-windows.bat
  if errorlevel 1 exit /b %ERRORLEVEL%
  powershell -NoProfile -ExecutionPolicy Bypass -Command ". .\.cargo\env-windows.ps1; cargo xtask check-fast"
  exit /b %ERRORLEVEL%
)

echo usage: scripts\check.bat [fast^|core^|workspace^|compat^|full^|windows]
exit /b 2
