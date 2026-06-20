$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$CargoDir = Join-Path $Root ".cargo"
$Config = Join-Path $CargoDir "config.toml"

if (!(Test-Path $CargoDir)) {
    New-Item -ItemType Directory -Path $CargoDir | Out-Null
}
if (!(Test-Path $Config)) {
    New-Item -ItemType File -Path $Config | Out-Null
}

$text = Get-Content -Path $Config -Raw
if ($text -match 'CXXFLAGS_x86_64_pc_windows_gnu') {
    Write-Host "Windows RocksDB cstdint flags already present"
    exit 0
}

$block = @'

# Windows GNU RocksDB fix. librocksdb-sys 0.16 / RocksDB 8.10 can fail on
# x86_64-pc-windows-gnu because rocksdb/options/offpeak_time_info.h uses
# int64_t without pulling in <cstdint>. cc-rs passes these flags to g++.
# The target-specific variables keep this from changing Linux/MSVC builds.
[env]
"CXXFLAGS_x86_64_pc_windows_gnu" = { value = "-include cstdint", force = false }
"CXXFLAGS_x86_64-pc-windows-gnu" = { value = "-include cstdint", force = false }
'@

Add-Content -Path $Config -Value $block
Write-Host "patched .cargo/config.toml with Windows RocksDB cstdint flags"
