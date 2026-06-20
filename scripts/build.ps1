param(
  [ValidateSet("debug", "fast", "release", "workspace", "full", "check")]
  [string]$Mode = "debug"
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
  Write-Host "==> Generating Windows Cargo environment"
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "lib\repair-windows-bindgen-libclang.ps1")
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "==> Loading Windows Cargo environment"
. $EnvFile

function Invoke-Cargo {
  param([Parameter(Mandatory = $true)][string[]]$CargoArgs)
  Write-Host "==> cargo $($CargoArgs -join ' ')"
  & cargo @CargoArgs
  exit $LASTEXITCODE
}

switch ($Mode) {
  "debug"     { Invoke-Cargo -CargoArgs @("build") }
  "fast"      { Invoke-Cargo -CargoArgs @("build") }
  "release"   { Invoke-Cargo -CargoArgs @("build", "--release") }
  "workspace" { Invoke-Cargo -CargoArgs @("build", "--workspace") }
  "full"      { Invoke-Cargo -CargoArgs @("build", "--workspace", "--all-targets") }
  "check"     { Invoke-Cargo -CargoArgs @("check") }
}
