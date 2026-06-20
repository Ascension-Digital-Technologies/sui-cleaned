$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$CargoDir = Join-Path $Root ".cargo"
$Config = Join-Path $CargoDir "config.toml"

if (!(Test-Path $CargoDir)) {
  New-Item -ItemType Directory -Path $CargoDir | Out-Null
}
if (!(Test-Path $Config)) {
  New-Item -ItemType File -Path $Config | Out-Null
}

$text = Get-Content -Path $Config -Raw
if ($text -notmatch '\[env\]') {
  Add-Content -Path $Config -Value ""
  Add-Content -Path $Config -Value "[env]"
}

function Add-ConfigLine($needle, $line) {
  $current = Get-Content -Path $Config -Raw
  if ($current -notmatch [regex]::Escape($needle)) {
    Add-Content -Path $Config -Value $line
  }
}

Add-ConfigLine "CXXFLAGS_x86_64_pc_windows_gnu" '"CXXFLAGS_x86_64_pc_windows_gnu" = { value = "-include cstdint", force = false }'
Add-ConfigLine "CXXFLAGS_x86_64-pc-windows-gnu" '"CXXFLAGS_x86_64-pc-windows-gnu" = { value = "-include cstdint", force = false }'

Write-Host "Windows RocksDB cstdint flags are configured."
