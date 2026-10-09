@echo off
rem Super Dodgeball - start (oompaloompa0730)
rem Korean messages live in start.ps1 (cmd can break on Korean text in .bat files).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start.ps1"
if errorlevel 1 pause
