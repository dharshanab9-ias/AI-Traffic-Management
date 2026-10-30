@echo off
title ITMS Project Installer & Setup
echo ========================================================
echo  Installing ITMS Dependencies for Fresh Clone
echo ========================================================
echo.

echo [1/2] Setting up Python backend virtual environment...
cd /d "%~dp0backend"
if not exist ".venv" (
    python -m venv .venv
)
call .venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt
cd /d "%~dp0"
echo [Backend OK]

echo.
echo [2/2] Installing React frontend npm packages...
cd /d "%~dp0frontend"
call npm install
cd /d "%~dp0"
echo [Frontend OK]

echo.
echo ========================================================
echo  Setup Completed Successfully!
echo  Run start_all.bat to launch the application.
echo ========================================================
pause
