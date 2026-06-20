
@echo off
setlocal EnableExtensions
cd /d "%~dp0\.."

set "MODE=%~1"
if "%MODE%"=="" set "MODE=target"

if /I "%MODE%"=="target" (
  cargo clean
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="native" (
  cargo clean -p librocksdb-sys
  cargo clean -p rocksdb
  cargo clean -p tikv-jemalloc-sys
  exit /b %ERRORLEVEL%
)
if /I "%MODE%"=="xtask" (
  if exist target\xtask-output rmdir /s /q target\xtask-output
  exit /b 0
)

echo usage: scripts\clean.bat [target^|native^|xtask]
exit /b 2
