# Dot-source this file before direct Cargo commands on Windows GNU:
#   . .\.cargo\env-windows.ps1
# Wrapper scripts load this automatically.
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
. (Join-Path $Root "scripts\lib\windows-env.ps1")
