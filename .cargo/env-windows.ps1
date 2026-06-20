# Dot-source this file before direct cargo commands on Windows GNU:
#   . .\.cargo\env-windows.ps1
if (-not $env:MSYS2_ROOT) { $env:MSYS2_ROOT = "C:\msys64" }
$mingwBin = Join-Path $env:MSYS2_ROOT "mingw64\bin"
$usrBin = Join-Path $env:MSYS2_ROOT "usr\bin"
$env:LIBCLANG_PATH = $mingwBin
$env:CLANG_PATH = Join-Path $mingwBin "clang.exe"
$env:Path = "$mingwBin;$usrBin;$env:Path"
