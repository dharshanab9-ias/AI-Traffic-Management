@echo off
title ITMS Unified Launcher
echo ========================================================
echo  Intelligent Traffic Management System (ITMS) Launcher
echo ========================================================
echo.

:: 1. Check Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in your system PATH!
    echo Please install Python 3.10+ from https://www.python.org/
    pause
    exit /b 1
)

:: 2. Check Node.js
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed or not in your system PATH!
    echo Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
)

:: 3. Auto-setup backend virtual environment if missing
if not exist "%~dp0backend\.venv" (
    echo [Setup] Backend virtual environment not found. Setting up now...
    cd /d "%~dp0backend"
    python -m venv .venv
    call .venv\Scripts\activate.bat
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    cd /d "%~dp0"
    echo [Setup] Backend setup complete!
    echo.
)

:: 4. Auto-setup frontend node_modules if missing
if not exist "%~dp0frontend\node_modules" (
    echo [Setup] Frontend node_modules not found. Running npm install...
    cd /d "%~dp0frontend"
    call npm install
    cd /d "%~dp0"
    echo [Setup] Frontend dependencies installed!
    echo.
)

:: 5. Launch Backend on Port 8005
echo Starting Backend Service (FastAPI + YOLOv8) on Port 8005...
if exist "%~dp0backend\.venv\Scripts\python.exe" (
    start "ITMS Backend" cmd /k "cd /d %~dp0backend && .venv\Scripts\python -m uvicorn main:app --host 0.0.0.0 --port 8005"
) else (
    start "ITMS Backend" cmd /k "cd /d %~dp0backend && python -m uvicorn main:app --host 0.0.0.0 --port 8005"
)

timeout /t 4 /nobreak >nul

:: 6. Launch Frontend on Port 5173
echo Starting Frontend Web Dashboard (React + Vite) on Port 5173...
start "ITMS Frontend" cmd /k "cd /d %~dp0frontend && npm run dev"

timeout /t 2 /nobreak >nul

echo.
echo ========================================================
echo  ITMS IS RUNNING!
echo ========================================================
echo   - Web Dashboard: http://localhost:5173
echo   - Backend API:   http://localhost:8005
echo   - API Swagger:   http://localhost:8005/docs
echo ========================================================
echo.
pause
