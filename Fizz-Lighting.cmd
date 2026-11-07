@echo off
setlocal
rem Launches the Fizz Lighting GUI. No install, no admin needed.
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0fizz-gui.ps1"
if errorlevel 1 pause
