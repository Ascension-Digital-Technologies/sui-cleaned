@echo off
setlocal EnableExtensions
cd /d "%~dp0\.."

set "MODE=%~1"
if "%MODE%"=="" set "MODE=debug"

call scripts\repair-windows.bat
if errorlevel 1 exit /b %ERRORLEVEL%
call scripts\lib\windows-env.bat
if errorlevel 1 exit /b %ERRORLEVEL%

if /I "%MODE%"=="debug" (
  cargo build
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="fast" (
  cargo build
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="release" (
  cargo build --release
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="workspace" (
  cargo build --workspace
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="full" (
  cargo build --workspace --all-targets
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="check" (
  cargo check
  exit /b %ERRORLEVEL%
)

echo usage: scripts\build.bat [debug^|release^|workspace^|full^|check]
exit /b 2
