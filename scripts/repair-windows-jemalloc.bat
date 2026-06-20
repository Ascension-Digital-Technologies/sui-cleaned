@echo off
setlocal
set ROOT=%~dp0..
python "%ROOT%\scripts\repair-windows-jemalloc.py"
if errorlevel 1 exit /b %errorlevel%
echo.
echo IMPORTANT: if tikv-jemalloc-sys already started compiling, run:
echo   cargo clean -p tikv-jemalloc-sys
echo   cargo clean -p tikv-jemallocator
echo   cargo clean -p tikv-jemalloc-ctl
echo then rerun cargo.
