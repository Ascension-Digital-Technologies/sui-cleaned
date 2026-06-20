@echo off
setlocal DisableDelayedExpansion

if "%MSYS2_ROOT%"=="" set "MSYS2_ROOT=C:\msys64"
set "MINGW_BIN=%MSYS2_ROOT%\mingw64\bin"
set "USR_BIN=%MSYS2_ROOT%\usr\bin"

if not exist "%MINGW_BIN%\libclang.dll" (
  echo missing libclang.dll: %MINGW_BIN%\libclang.dll
  echo Install MSYS2 MinGW64 clang/libclang packages or set MSYS2_ROOT.
  exit /b 1
)
if not exist "%MINGW_BIN%\clang.exe" (
  echo missing clang.exe: %MINGW_BIN%\clang.exe
  echo Install MSYS2 MinGW64 clang/libclang packages or set MSYS2_ROOT.
  exit /b 1
)

set "LIBCLANG_PATH=%MINGW_BIN%"
set "CLANG_PATH=%MINGW_BIN%\clang.exe"
set "BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu=--target=x86_64-w64-windows-gnu"
set "BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu=--target=x86_64-w64-windows-gnu"
set "CXXFLAGS_x86_64_pc_windows_gnu=-include cstdint"
set "CXXFLAGS_x86_64-pc-windows-gnu=-include cstdint"

echo %PATH% | find /I "%MINGW_BIN%" >nul
if errorlevel 1 set "PATH=%MINGW_BIN%;%USR_BIN%;%PATH%"

endlocal & (
  set "MSYS2_ROOT=%MSYS2_ROOT%"
  set "LIBCLANG_PATH=%LIBCLANG_PATH%"
  set "CLANG_PATH=%CLANG_PATH%"
  set "BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu=%BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu%"
  set "BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu=%BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu%"
  set "CXXFLAGS_x86_64_pc_windows_gnu=%CXXFLAGS_x86_64_pc_windows_gnu%"
  set "CXXFLAGS_x86_64-pc-windows-gnu=%CXXFLAGS_x86_64-pc-windows-gnu%"
  set "PATH=%PATH%"
)
