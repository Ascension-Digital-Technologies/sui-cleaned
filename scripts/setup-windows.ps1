$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

if ([string]::IsNullOrWhiteSpace($env:MSYS2_ROOT)) {
  $env:MSYS2_ROOT = "C:\msys64"
}
$pacman = Join-Path $env:MSYS2_ROOT "usr\bin\pacman.exe"
if (!(Test-Path $pacman)) {
  throw "Missing MSYS2 pacman: $pacman. Install MSYS2 or set MSYS2_ROOT."
}

& $pacman -Syu --noconfirm
& $pacman -S --needed --noconfirm `
  diffutils `
  make `
  mingw-w64-x86_64-clang `
  mingw-w64-x86_64-gcc `
  mingw-w64-x86_64-llvm `
  mingw-w64-x86_64-lld `
  mingw-w64-x86_64-pkgconf `
  pkgconf

& scripts\repair-windows.bat
Write-Host "Windows native build dependencies are ready."
Write-Host "Use scripts\build.bat debug or scripts\check.bat fast."
