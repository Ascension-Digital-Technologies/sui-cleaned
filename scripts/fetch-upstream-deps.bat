@echo off
setlocal enabledelayedexpansion
set ROOT=%~dp0..
set SRC=%~1
set TMP=%ROOT%\.upstream-tmp\sui

if "%SRC%"=="" (
  if not exist "%TMP%\.git" (
    git clone --depth 1 https://github.com/MystenLabs/sui.git "%TMP%"
    if errorlevel 1 exit /b %errorlevel%
  ) else (
    git -C "%TMP%" fetch --depth 1 origin main
    if errorlevel 1 exit /b %errorlevel%
    git -C "%TMP%" checkout FETCH_HEAD
    if errorlevel 1 exit /b %errorlevel%
  )
  set SRC=%TMP%
)

if not exist "%SRC%\Cargo.toml" (
  echo error: upstream Sui source not found at %SRC%
  exit /b 1
)

rem Canonical cleaned layout:
rem   crates\execution\move-vm\move      upstream external-crates\move
rem   domain folders under crates\        synced Sui crates by domain
if exist "%ROOT%\crates\execution\move-vm\move" rmdir /s /q "%ROOT%\crates\execution\move-vm\move"
if not exist "%ROOT%\crates\execution\move-vm" mkdir "%ROOT%\crates\execution\move-vm"
if exist "%SRC%\external-crates\move" (
  robocopy "%SRC%\external-crates\move" "%ROOT%\crates\execution\move-vm\move" /E >nul
  if !ERRORLEVEL! GEQ 8 exit /b !ERRORLEVEL!
) else (
  echo warning: upstream external-crates\move not found
)

python "%ROOT%\scripts\sync-upstream-domain-crates.py" "%SRC%"
if errorlevel 1 exit /b %errorlevel%
python "%ROOT%\scripts\repair-upstream-direct-paths.py"
if errorlevel 1 exit /b %errorlevel%
python "%ROOT%\scripts\repair-move-uint-version.py"
if errorlevel 1 exit /b %errorlevel%
python "%ROOT%\scripts\repair-windows-jemalloc.py"
if errorlevel 1 exit /b %errorlevel%
python "%ROOT%\scripts\audit-workspace-inheritance.py"
if errorlevel 1 exit /b %errorlevel%
python "%ROOT%\scripts\audit-direct-paths.py"
if errorlevel 1 exit /b %errorlevel%

echo Upstream deps synced into clean domain folders.
echo Next: cargo metadata --format-version 1 --no-deps
