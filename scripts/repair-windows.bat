@echo off
setlocal EnableExtensions
cd /d "%~dp0\.."
set "ROOT=%CD%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\lib\repair-windows-bindgen-libclang.ps1" || exit /b %ERRORLEVEL%
python "%ROOT%\scripts\lib\repair-windows-jemalloc.py" || exit /b %ERRORLEVEL%
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\lib\repair-windows-rocksdb-cstdint.ps1" || exit /b %ERRORLEVEL%
python "%ROOT%\scripts\lib\repair-move-uint-version.py" || exit /b %ERRORLEVEL%

echo Windows repair passes complete.
echo Use scripts\build.bat or scripts\check.bat so libclang/MSYS2 PATH is loaded automatically.
echo For direct PowerShell cargo commands, run: . .\.cargo\env-windows.ps1
exit /b 0
