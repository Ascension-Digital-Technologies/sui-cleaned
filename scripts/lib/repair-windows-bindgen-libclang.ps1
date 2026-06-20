$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
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

if (!(Test-Path (Split-Path $config))) {
  New-Item -ItemType Directory -Path (Split-Path $config) | Out-Null
}
if (!(Test-Path $config)) {
  New-Item -ItemType File -Path $config | Out-Null
}

$text = Get-Content $config -Raw
if ($text -notmatch '\[env\]') {
  Add-Content $config ""
  Add-Content $config "[env]"
}

function TomlPath($p) {
  return ($p -replace '\\', '\\\\')
}
function Add-ConfigLine($needle, $line) {
  $current = Get-Content $config -Raw
  if ($current -notmatch [regex]::Escape($needle)) {
    Add-Content $config $line
  }
}

Add-ConfigLine "LIBCLANG_PATH" ('"LIBCLANG_PATH" = { value = "' + (TomlPath $mingwBin) + '", force = false }')
Add-ConfigLine "CLANG_PATH" ('"CLANG_PATH" = { value = "' + (TomlPath $clangExe) + '", force = false }')
Add-ConfigLine "BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu" '"BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu" = { value = "--target=x86_64-w64-windows-gnu", force = false }'
Add-ConfigLine "BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" '"BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" = { value = "--target=x86_64-w64-windows-gnu", force = false }'

$envFile = Join-Path $root ".cargo\env-windows.ps1"
Set-Content $envFile @"
# Dot-source this file before running direct Cargo commands on Windows GNU:
#   . .\.cargo\env-windows.ps1
# The wrapper scripts load the same environment automatically.
`$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace(`$env:MSYS2_ROOT)) {
  `$env:MSYS2_ROOT = "$msysRoot"
}

`$mingwBin = Join-Path `$env:MSYS2_ROOT "mingw64\bin"
`$usrBin = Join-Path `$env:MSYS2_ROOT "usr\bin"
`$clangExe = Join-Path `$mingwBin "clang.exe"
`$libclangDll = Join-Path `$mingwBin "libclang.dll"

if (!(Test-Path `$libclangDll)) { throw "missing libclang.dll: `$libclangDll. Install MSYS2 MinGW64 clang/libclang packages or set MSYS2_ROOT." }
if (!(Test-Path `$clangExe)) { throw "missing clang.exe: `$clangExe. Install MSYS2 MinGW64 clang/libclang packages or set MSYS2_ROOT." }

`$env:LIBCLANG_PATH = `$mingwBin
`$env:CLANG_PATH = `$clangExe
`$env:CXXFLAGS_x86_64_pc_windows_gnu = "-include cstdint"
Set-Item -Path Env:"CXXFLAGS_x86_64-pc-windows-gnu" -Value "-include cstdint"
`$env:BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu = "--target=x86_64-w64-windows-gnu"
Set-Item -Path Env:"BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" -Value "--target=x86_64-w64-windows-gnu"

`$parts = `$env:Path -split ';'
if (`$parts -notcontains `$mingwBin) { `$env:Path = "`$mingwBin;`$usrBin;`$env:Path" }

Write-Host "Windows Cargo environment loaded."
Write-Host "LIBCLANG_PATH=`$env:LIBCLANG_PATH"
"@

$envBat = Join-Path $root ".cargo\env-windows.bat"
Set-Content $envBat @"
@echo off
if "%MSYS2_ROOT%"=="" set "MSYS2_ROOT=$msysRoot"
set "MINGW_BIN=%MSYS2_ROOT%\mingw64\bin"
set "USR_BIN=%MSYS2_ROOT%\usr\bin"
if not exist "%MINGW_BIN%\libclang.dll" echo missing libclang.dll: %MINGW_BIN%\libclang.dll && exit /b 1
if not exist "%MINGW_BIN%\clang.exe" echo missing clang.exe: %MINGW_BIN%\clang.exe && exit /b 1
set "LIBCLANG_PATH=%MINGW_BIN%"
set "CLANG_PATH=%MINGW_BIN%\clang.exe"
set "CXXFLAGS_x86_64_pc_windows_gnu=-include cstdint"
set "CXXFLAGS_x86_64-pc-windows-gnu=-include cstdint"
set "BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu=--target=x86_64-w64-windows-gnu"
set "BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu=--target=x86_64-w64-windows-gnu"
echo %PATH% | find /I "%MINGW_BIN%" >nul
if errorlevel 1 set "PATH=%MINGW_BIN%;%USR_BIN%;%PATH%"
"@

Write-Host "windows bindgen/libclang repair applied"
Write-Host "libclang: $libclangDll"
Write-Host "clang:    $clangExe"
Write-Host ""
Write-Host "For direct cargo commands in this PowerShell session, run:"
Write-Host "  . .\.cargo\env-windows.ps1"
