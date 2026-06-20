\
@echo off
setlocal
cd /d "%~dp0\.."
echo Workspace check: all active packages, normal lib/bin targets only.
cargo check --workspace
