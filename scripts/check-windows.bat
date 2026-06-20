@echo off
setlocal
if "%MSYS2_ROOT%"=="" set "MSYS2_ROOT=C:\msys64"
set "PATH=%MSYS2_ROOT%\mingw64\bin;%MSYS2_ROOT%\usr\bin;%PATH%"
set "LIBCLANG_PATH=%MSYS2_ROOT%\mingw64\bin"
set "CLANG_PATH=%MSYS2_ROOT%\mingw64\bin\clang.exe"
set "CXXFLAGS_x86_64_pc_windows_gnu=-include cstdint"
set "CXXFLAGS_x86_64-pc-windows-gnu=-include cstdint"
cargo check %*
exit /b %ERRORLEVEL%
