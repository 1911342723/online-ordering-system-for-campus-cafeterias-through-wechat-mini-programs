@echo off
echo ==========================================
echo   Stop All Services
echo ==========================================
echo.

echo [1/3] Stopping Backend (8080)...
for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr ":8080 " ^| findstr "LISTENING"') do (
    echo   Killing PID=%%a
    taskkill /F /PID %%a >nul 2>&1
)
echo   Done

echo [2/3] Stopping Admin Frontend (3000)...
for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr ":3000 " ^| findstr "LISTENING"') do (
    echo   Killing PID=%%a
    taskkill /F /PID %%a >nul 2>&1
)
echo   Done

echo [3/3] Stopping Merchant Frontend (3001)...
for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr ":3001 " ^| findstr "LISTENING"') do (
    echo   Killing PID=%%a
    taskkill /F /PID %%a >nul 2>&1
)
echo   Done

echo.
echo   All services stopped!
echo.
pause
