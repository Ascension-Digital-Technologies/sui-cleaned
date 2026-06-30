$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$config = Join-Path $root ".cargo\config.toml"
$envFile = Join-Path $root ".cargo\env-windows.ps1"
$envBat = Join-Path $root ".cargo\env-windows.bat"

if (!(Test-Path (Split-Path $config))) { New-Item -ItemType Directory -Path (Split-Path $config) | Out-Null }
if (!(Test-Path $config)) { New-Item -ItemType File -Path $config | Out-Null }

$text = Get-Content $config -Raw
if ($text -notmatch '(?m)^\[env\]\s*$') {
  Add-Content $config ""
  Add-Content $config "[env]"
}

function Remove-ConfigLine($key) {
  $current = Get-Content $config -Raw
  $pattern = '(?m)^"?' + [regex]::Escape($key) + '"?\s*=.*\r?\n?'
  $updated = [regex]::Replace($current, $pattern, '')
  if ($updated -ne $current) { Set-Content $config $updated }
}

function Add-Or-ReplaceConfigLine($key, $line) {
  $current = Get-Content $config -Raw
  $pattern = '(?m)^"?' + [regex]::Escape($key) + '"?\s*=.*$'
  if ($current -match $pattern) {
    $updated = [regex]::Replace($current, $pattern, $line)
    Set-Content $config $updated
  } else {
    Add-Content $config $line
  }
}

# Do not commit a machine-specific libclang path into Cargo config. Build scripts
# discover MSYS2/LLVM dynamically and export LIBCLANG_PATH in-process instead.
Remove-ConfigLine "LIBCLANG_PATH"
Remove-ConfigLine "CLANG_PATH"
Add-Or-ReplaceConfigLine "CXXFLAGS_x86_64_pc_windows_gnu" '"CXXFLAGS_x86_64_pc_windows_gnu" = { value = "-include cstdint", force = false }'
Add-Or-ReplaceConfigLine "CXXFLAGS_x86_64-pc-windows-gnu" '"CXXFLAGS_x86_64-pc-windows-gnu" = { value = "-include cstdint", force = false }'
Add-Or-ReplaceConfigLine "BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu" '"BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu" = { value = "--target=x86_64-w64-windows-gnu", force = false }'
Add-Or-ReplaceConfigLine "BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" '"BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" = { value = "--target=x86_64-w64-windows-gnu", force = false }'

Set-Content $envFile @"
# Dot-source this file before direct Cargo commands on Windows GNU:
#   . .\.cargo\env-windows.ps1
# Wrapper scripts load this automatically.
`$ErrorActionPreference = "Stop"
`$Root = (Resolve-Path (Join-Path `$PSScriptRoot "..")).Path
. (Join-Path `$Root "scripts\lib\windows-env.ps1")
"@

Set-Content $envBat @"
@echo off
call "%~dp0..\scripts\lib\windows-env.bat"
"@

Write-Host "windows bindgen/libclang repair applied"
Write-Host "Cargo config now avoids hardcoded LIBCLANG_PATH/CLANG_PATH entries."
Write-Host "For direct cargo commands in this PowerShell session, run:"
Write-Host "  . .\.cargo\env-windows.ps1"
