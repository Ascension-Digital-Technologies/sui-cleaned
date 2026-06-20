$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($env:MSYS2_ROOT)) {
  $env:MSYS2_ROOT = "C:\msys64"
}

$mingwBin = Join-Path $env:MSYS2_ROOT "mingw64\bin"
$usrBin = Join-Path $env:MSYS2_ROOT "usr\bin"
$clangExe = Join-Path $mingwBin "clang.exe"
$libclangDll = Join-Path $mingwBin "libclang.dll"

if (!(Test-Path $libclangDll)) {
  throw "missing libclang.dll: $libclangDll. Install MSYS2 MinGW64 clang/libclang packages or set MSYS2_ROOT."
}
if (!(Test-Path $clangExe)) {
  throw "missing clang.exe: $clangExe. Install MSYS2 MinGW64 clang/libclang packages or set MSYS2_ROOT."
}

$env:LIBCLANG_PATH = $mingwBin
$env:CLANG_PATH = $clangExe
$env:CXXFLAGS_x86_64_pc_windows_gnu = "-include cstdint"
Set-Item -Path Env:"CXXFLAGS_x86_64-pc-windows-gnu" -Value "-include cstdint"
$env:BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu = "--target=x86_64-w64-windows-gnu"
Set-Item -Path Env:"BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" -Value "--target=x86_64-w64-windows-gnu"

$parts = $env:Path -split ';'
if ($parts -notcontains $mingwBin) {
  $env:Path = "$mingwBin;$usrBin;$env:Path"
}
