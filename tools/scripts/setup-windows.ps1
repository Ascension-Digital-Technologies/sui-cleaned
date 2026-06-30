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
  pkgconf `
  mingw-w64-x86_64-bzip2 `
  mingw-w64-x86_64-clang `
  mingw-w64-x86_64-cmake `
  mingw-w64-x86_64-gcc `
  mingw-w64-x86_64-lld `
  mingw-w64-x86_64-llvm `
  mingw-w64-x86_64-ninja `
  mingw-w64-x86_64-openssl `
  mingw-w64-x86_64-pkgconf `
  mingw-w64-x86_64-protobuf `
  mingw-w64-x86_64-snappy `
  mingw-w64-x86_64-zlib `
  mingw-w64-x86_64-zstd

& scripts\repair-windows.bat
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Windows native build dependencies are ready."
Write-Host "Use scripts\build.bat debug or scripts\check.bat fast."
