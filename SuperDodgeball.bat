@echo off
rem Super Dodgeball launcher: git pull -> rojo serve -> Roblox Studio
rem Put this file on the Desktop. The repo is cloned next to it on first run.

set REPO=%~dp0roblox-super-dodgeball
set PLACE=%REPO%\SuperDodgeball.rbxl

if not exist "%REPO%\.git" (
    echo [1/4] First run: cloning repo...
    git clone https://github.com/kimtaenim/roblox-super-dodgeball "%REPO%"
    if errorlevel 1 goto :fail
) else (
    echo [1/4] git pull...
    git -C "%REPO%" pull
    if errorlevel 1 goto :fail
)

cd /d "%REPO%"

if not exist "%PLACE%" (
    echo [2/4] Building place file for the first time...
    rojo build -o "%PLACE%"
    if errorlevel 1 goto :fail
) else (
    echo [2/4] Place file exists, keeping Studio edits.
)

echo [3/4] Starting rojo serve in a new window...
start "rojo serve - Super Dodgeball" cmd /k rojo serve

echo [4/4] Opening Roblox Studio...
timeout /t 2 /nobreak >nul
start "" "%PLACE%"

echo Done. In Studio: Rojo plugin -> Connect.
timeout /t 5
exit /b 0

:fail
echo.
echo Something failed. Check git / rojo install, then run again.
pause
exit /b 1
