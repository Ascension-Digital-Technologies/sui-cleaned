@echo off
set ROOT=%~dp0..
python "%ROOT%\scripts\audit-workspace-inheritance.py"
if errorlevel 1 exit /b %errorlevel%
python "%ROOT%\scripts\repair-upstream-direct-paths.py"
if errorlevel 1 exit /b %errorlevel%
echo Repaired upstream workspace paths.
