\
@echo off
setlocal
cd /d "%~dp0\.."
python scripts\repair-move-uint-version.py
