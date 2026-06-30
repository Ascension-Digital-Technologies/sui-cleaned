param(
  [ValidateSet("fast", "core", "workspace", "compat", "full", "windows")]
  [string]$Mode = "fast"
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $Root

Write-Host "==> Repository root: $Root"
Write-Host "==> Preparing Windows native check environment"
& (Join-Path $PSScriptRoot "repair-windows.bat")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$EnvFile = Join-Path $Root ".cargo\env-windows.ps1"
Write-Host "==> Loading Windows Cargo environment"
. $EnvFile

function Invoke-Cargo {
  param([Parameter(Mandatory = $true)][string[]]$CargoArgs)
  Write-Host "==> cargo $($CargoArgs -join ' ')"
  & cargo @CargoArgs
  exit $LASTEXITCODE
}

switch ($Mode) {
  "fast"      { Invoke-Cargo -CargoArgs @("xtask", "check-fast") }
  "core"      { Invoke-Cargo -CargoArgs @("xtask", "check-core") }
  "workspace" { Invoke-Cargo -CargoArgs @("xtask", "check-workspace") }
  "compat"    { Invoke-Cargo -CargoArgs @("xtask", "check-sui-compat") }
  "full"      { Invoke-Cargo -CargoArgs @("xtask", "check-full") }
  "windows"   { Invoke-Cargo -CargoArgs @("xtask", "check-fast") }
}
