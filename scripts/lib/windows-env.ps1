$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$EnvFile = Join-Path $Root ".cargo\env-windows.ps1"

if (!(Test-Path $EnvFile)) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "repair-windows-bindgen-libclang.ps1")
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

. $EnvFile
