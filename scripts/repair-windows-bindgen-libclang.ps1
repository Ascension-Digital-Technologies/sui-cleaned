$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$config = Join-Path $root ".cargo\config.toml"
$msysRoot = $env:MSYS2_ROOT
if ([string]::IsNullOrWhiteSpace($msysRoot)) {
  $msysRoot = "C:\msys64"
}

$mingwBin = Join-Path $msysRoot "mingw64\bin"
$usrBin = Join-Path $msysRoot "usr\bin"
$clangExe = Join-Path $mingwBin "clang.exe"
$libclangDll = Join-Path $mingwBin "libclang.dll"

if (!(Test-Path $mingwBin)) {
  Write-Host "missing MSYS2 mingw64 bin: $mingwBin"
  Write-Host "install MSYS2/MinGW64 or set MSYS2_ROOT to the correct root"
  exit 1
}
if (!(Test-Path $clangExe)) {
  Write-Host "missing clang.exe: $clangExe"
  Write-Host "install the MSYS2 mingw64 clang/libclang packages"
  exit 1
}
if (!(Test-Path $libclangDll)) {
  Write-Host "missing libclang.dll: $libclangDll"
  Write-Host "install the MSYS2 mingw64 libclang package"
  exit 1
}

$text = Get-Content $config -Raw
if ($text -notmatch '\[env\]') {
  Add-Content $config ""
  Add-Content $config "[env]"
}
function Add-ConfigLine($needle, $line) {
  $current = Get-Content $config -Raw
  if ($current -notmatch [regex]::Escape($needle)) {
    Add-Content $config $line
  }
}
Add-ConfigLine "LIBCLANG_PATH" '"LIBCLANG_PATH" = { value = "C:\\msys64\\mingw64\\bin", force = false }'
Add-ConfigLine "CLANG_PATH" '"CLANG_PATH" = { value = "C:\\msys64\\mingw64\\bin\\clang.exe", force = false }'
Add-ConfigLine "BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu" '"BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu" = { value = "--target=x86_64-w64-windows-gnu", force = false }'
Add-ConfigLine "BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" '"BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" = { value = "--target=x86_64-w64-windows-gnu", force = false }'

$envFile = Join-Path $root ".cargo\env-windows.ps1"
Set-Content $envFile @"
# Dot-source this file before running direct cargo commands on Windows GNU:
#   . .\.cargo\env-windows.ps1
`$env:MSYS2_ROOT = if (`$env:MSYS2_ROOT) { `$env:MSYS2_ROOT } else { "$msysRoot" }
`$env:LIBCLANG_PATH = "$mingwBin"
`$env:CLANG_PATH = "$clangExe"
`$env:Path = "$mingwBin;$usrBin;`$env:Path"
"@

Write-Host "windows bindgen/libclang repair applied"
Write-Host "libclang: $libclangDll"
Write-Host "clang:    $clangExe"
Write-Host ""
Write-Host "For direct cargo commands in this PowerShell session, run:"
Write-Host "  . .\.cargo\env-windows.ps1"
