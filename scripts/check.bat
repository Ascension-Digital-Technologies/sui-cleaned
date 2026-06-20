@echo off
setlocal
if not exist reports mkdir reports
python "%ROOT%\scripts\audit-workspace-inheritance.py"
if errorlevel 1 exit /b %errorlevel%
python "%ROOT%\scripts\audit-direct-paths.py"
if errorlevel 1 exit /b %errorlevel%
cargo metadata --format-version 1 --no-deps > reports\cargo-metadata.json
if errorlevel 1 exit /b %errorlevel%
cargo check --workspace --all-targets
