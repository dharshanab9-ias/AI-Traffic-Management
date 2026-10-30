@echo off
title ITMS AI Backend Server
cd /d "%~dp0backend"
echo =======================================================
echo Starting FastAPI ITMS AI Backend on http://localhost:8005
echo =======================================================
if not exist ".venv\Scripts\python.exe" (
    echo Creating virtual environment and installing requirements...
    python -m venv .venv
    call .venv\Scripts\activate.bat
    pip install -r requirements.txt
)
if exist ".venv\Scripts\python.exe" (
    .venv\Scripts\python -m uvicorn main:app --host 0.0.0.0 --port 8005 --reload
) else (
    python -m uvicorn main:app --host 0.0.0.0 --port 8005 --reload
)
pause
