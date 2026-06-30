@echo off
setlocal EnableExtensions
cd /d "%~dp0\.."

if "%MSYS2_ROOT%"=="" set "MSYS2_ROOT=C:\msys64"
set "PACMAN=%MSYS2_ROOT%\usr\bin\pacman.exe"

if not exist "%PACMAN%" (
  echo Missing MSYS2 pacman: %PACMAN%
  echo Install MSYS2 or set MSYS2_ROOT to the correct root.
  exit /b 1
)

"%PACMAN%" -Syu --noconfirm
"%PACMAN%" -S --needed --noconfirm ^
  diffutils ^
  make ^
  pkgconf ^
  mingw-w64-x86_64-bzip2 ^
  mingw-w64-x86_64-clang ^
  mingw-w64-x86_64-cmake ^
  mingw-w64-x86_64-gcc ^
  mingw-w64-x86_64-lld ^
  mingw-w64-x86_64-llvm ^
  mingw-w64-x86_64-ninja ^
  mingw-w64-x86_64-openssl ^
  mingw-w64-x86_64-pkgconf ^
  mingw-w64-x86_64-protobuf ^
  mingw-w64-x86_64-snappy ^
  mingw-w64-x86_64-zlib ^
  mingw-w64-x86_64-zstd

call scripts\repair-windows.bat
if errorlevel 1 exit /b %ERRORLEVEL%

echo Windows native build dependencies are ready.
echo Use scripts\build.bat debug or scripts\check.bat fast.
exit /b 0
