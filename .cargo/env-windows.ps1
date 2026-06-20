# Dot-source this file before running direct Cargo commands on Windows GNU:
#   . .\.cargo\env-windows.ps1
# The wrapper scripts load the same environment automatically.
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($env:MSYS2_ROOT)) { $env:MSYS2_ROOT = "C:\msys64" }

$candidateDirs = @(
  (Join-Path $env:MSYS2_ROOT "mingw64\bin"),
  (Join-Path $env:MSYS2_ROOT "ucrt64\bin"),
  (Join-Path $env:MSYS2_ROOT "clang64\bin"),
  (Join-Path $env:MSYS2_ROOT "usr\bin"),
  "C:\Program Files\LLVM\bin"
) | Where-Object { Test-Path $_ }

$libclang = $null
foreach ($dir in $candidateDirs) {
  $hit = Get-ChildItem -Path $dir -Filter "libclang*.dll" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($hit) { $libclang = $hit.FullName; break }
}
if (-not $libclang) { throw "Unable to find libclang*.dll. Run scripts\setup-windows.bat or install MSYS2 clang/libclang." }

$clang = $null
foreach ($dir in $candidateDirs) {
  $hit = Get-ChildItem -Path $dir -Filter "clang*.exe" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^clang(-[0-9]+)?\.exe$' } | Select-Object -First 1
  if ($hit) { $clang = $hit.FullName; break }
}

$libclangDir = Split-Path $libclang -Parent
$usrBin = Join-Path $env:MSYS2_ROOT "usr\bin"
$env:LIBCLANG_PATH = $libclangDir
if ($clang) { $env:CLANG_PATH = $clang }
$env:CXXFLAGS_x86_64_pc_windows_gnu = "-include cstdint"
Set-Item -Path Env:"CXXFLAGS_x86_64-pc-windows-gnu" -Value "-include cstdint"
$env:BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu = "--target=x86_64-w64-windows-gnu"
Set-Item -Path Env:"BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" -Value "--target=x86_64-w64-windows-gnu"

$parts = $env:Path -split ';'
if ($parts -notcontains $libclangDir) { $env:Path = "$libclangDir;$usrBin;$env:Path" }

Write-Host "Windows Cargo environment loaded."
Write-Host "LIBCLANG_PATH=$env:LIBCLANG_PATH"
if ($env:CLANG_PATH) { Write-Host "CLANG_PATH=$env:CLANG_PATH" }
