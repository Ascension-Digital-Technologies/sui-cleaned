@echo off
setlocal EnableExtensions
cd /d "%~dp0\.."

set "MODE=%~1"
if "%MODE%"=="" set "MODE=fast"

rem Windows GNU native dependencies need MSYS2 mingw64\bin on PATH so bindgen can load libclang.dll.
call scripts\repair-windows.bat
if errorlevel 1 exit /b %ERRORLEVEL%
call scripts\lib\windows-env.bat
if errorlevel 1 exit /b %ERRORLEVEL%

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
  cargo xtask check-fast
  exit /b %ERRORLEVEL%
)

echo usage: scripts\check.bat [fast^|core^|workspace^|compat^|full^|windows]
exit /b 2
