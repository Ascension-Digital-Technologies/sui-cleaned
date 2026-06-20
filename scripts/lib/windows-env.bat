@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "ROOT=%~dp0..\.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location '%ROOT%'; if (!(Test-Path '.cargo\env-windows.ps1')) { & '.\scripts\lib\repair-windows-bindgen-libclang.ps1' }; . '.\.cargo\env-windows.ps1'; 'LIBCLANG_PATH=' + $env:LIBCLANG_PATH | Out-File -FilePath '%TEMP%\sui-clean-env.txt' -Encoding ascii; 'CLANG_PATH=' + $env:CLANG_PATH | Out-File -FilePath '%TEMP%\sui-clean-env.txt' -Encoding ascii -Append; 'PATH=' + $env:Path | Out-File -FilePath '%TEMP%\sui-clean-env.txt' -Encoding ascii -Append; 'CXXFLAGS_x86_64_pc_windows_gnu=' + $env:CXXFLAGS_x86_64_pc_windows_gnu | Out-File -FilePath '%TEMP%\sui-clean-env.txt' -Encoding ascii -Append; 'BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu=' + $env:BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu | Out-File -FilePath '%TEMP%\sui-clean-env.txt' -Encoding ascii -Append"
if errorlevel 1 exit /b %ERRORLEVEL%

for /f "usebackq tokens=1,* delims==" %%A in ("%TEMP%\sui-clean-env.txt") do set "%%A=%%B"
set "CXXFLAGS_x86_64-pc-windows-gnu=-include cstdint"
set "BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu=--target=x86_64-w64-windows-gnu"

endlocal & (
  set "LIBCLANG_PATH=%LIBCLANG_PATH%"
  set "CLANG_PATH=%CLANG_PATH%"
  set "PATH=%PATH%"
  set "CXXFLAGS_x86_64_pc_windows_gnu=%CXXFLAGS_x86_64_pc_windows_gnu%"
  set "CXXFLAGS_x86_64-pc-windows-gnu=%CXXFLAGS_x86_64-pc-windows-gnu%"
  set "BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu=%BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu%"
  set "BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu=%BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu%"
)
exit /b 0
