@echo off
setlocal
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%repair-windows-bindgen-libclang.bat" || exit /b %ERRORLEVEL%
call "%SCRIPT_DIR%repair-windows-jemalloc.bat" || exit /b %ERRORLEVEL%
call "%SCRIPT_DIR%repair-windows-rocksdb-cstdint.bat" || exit /b %ERRORLEVEL%
call "%SCRIPT_DIR%repair-move-uint-version.bat" || exit /b %ERRORLEVEL%
echo Windows repair passes complete.
echo If building from PowerShell, run: . .\.cargo\env-windows.ps1
exit /b 0
