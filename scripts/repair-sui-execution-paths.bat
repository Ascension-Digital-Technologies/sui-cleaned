@echo off
set ROOT=%~dp0..
python "%ROOT%\scripts\repair-upstream-direct-paths.py"
if errorlevel 1 exit /b %errorlevel%
python "%ROOT%\scripts\audit-direct-paths.py"
if errorlevel 1 exit /b %errorlevel%
echo Repaired upstream Sui execution direct paths.
