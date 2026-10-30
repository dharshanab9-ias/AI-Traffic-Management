@echo off
title ITMS Frontend Dashboard
cd /d "%~dp0frontend"
echo =======================================================
echo Starting ITMS Web Dashboard on http://localhost:5173
echo =======================================================
if not exist "node_modules" (
    echo Installing frontend dependencies...
    call npm install
)
npm run dev
pause
