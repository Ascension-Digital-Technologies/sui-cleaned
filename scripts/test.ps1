param(
  [ValidateSet("fast", "workspace", "full")]
  [string]$Mode = "fast"
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $Root

Write-Host "==> Repository root: $Root"
Write-Host "==> Running Windows repair passes"
& (Join-Path $PSScriptRoot "repair-windows.bat")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$EnvFile = Join-Path $Root ".cargo\env-windows.ps1"
if (!(Test-Path $EnvFile)) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "lib\repair-windows-bindgen-libclang.ps1")
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

. $EnvFile

function Invoke-Cargo {
  param([Parameter(Mandatory = $true)][string[]]$CargoArgs)
  Write-Host "==> cargo $($CargoArgs -join ' ')"
  & cargo @CargoArgs
  exit $LASTEXITCODE
}

switch ($Mode) {
  "fast"      { Invoke-Cargo -CargoArgs @("test", "--lib") }
  "workspace" { Invoke-Cargo -CargoArgs @("test", "--workspace", "--lib") }
  "full"      { Invoke-Cargo -CargoArgs @("test", "--workspace", "--all-targets") }
}
