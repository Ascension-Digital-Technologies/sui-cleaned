\
@echo off
setlocal
cd /d "%~dp0\.."
echo Fast check: workspace.default-members only, normal lib/bin targets.
cargo check
