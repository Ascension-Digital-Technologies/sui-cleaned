@echo off
setlocal EnableExtensions DisableDelayedExpansion

if "%MSYS2_ROOT%"=="" set "MSYS2_ROOT=C:\msys64"
set "USR_BIN=%MSYS2_ROOT%\usr\bin"
set "LIBCLANG_DLL="
set "CLANG_EXE="

for %%D in ("%MSYS2_ROOT%\mingw64\bin" "%MSYS2_ROOT%\ucrt64\bin" "%MSYS2_ROOT%\clang64\bin" "%MSYS2_ROOT%\usr\bin" "C:\Program Files\LLVM\bin") do (
  if exist "%%~D" (
    if not defined LIBCLANG_DLL (
      for %%F in ("%%~D\libclang*.dll") do (
        if exist "%%~fF" set "LIBCLANG_DLL=%%~fF"& set "LIBCLANG_DIR=%%~D"
      )
    )
    if not defined CLANG_EXE (
      if exist "%%~D\clang.exe" set "CLANG_EXE=%%~D\clang.exe"
      if not defined CLANG_EXE (
        for %%F in ("%%~D\clang-*.exe") do if exist "%%~fF" set "CLANG_EXE=%%~fF"
      )
    )
  )
)

if not defined LIBCLANG_DLL (
  echo unable to find libclang*.dll under %MSYS2_ROOT% or C:\Program Files\LLVM\bin
  echo Install MSYS2 clang/libclang packages or run scripts\setup-windows.bat.
  exit /b 1
)

set "LIBCLANG_PATH=%LIBCLANG_DIR%"
if defined CLANG_EXE set "CLANG_PATH=%CLANG_EXE%"
set "BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu=--target=x86_64-w64-windows-gnu"
set "BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu=--target=x86_64-w64-windows-gnu"
set "CXXFLAGS_x86_64_pc_windows_gnu=-include cstdint"
set "CXXFLAGS_x86_64-pc-windows-gnu=-include cstdint"

echo %PATH% | find /I "%LIBCLANG_DIR%" >nul
if errorlevel 1 set "PATH=%LIBCLANG_DIR%;%USR_BIN%;%PATH%"

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
