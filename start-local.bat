@echo off
echo ==========================================
echo   Campus Canteen System - Local Startup
echo ==========================================
echo.

echo [1/3] Checking environment...
where java >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java not found!
    pause
    exit /b 1
)
echo   Java: OK

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found!
    pause
    exit /b 1
)
echo   Node: OK

where mvn >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Maven not found!
    echo         Please install Maven and ensure mvn is in PATH.
    pause
    exit /b 1
)
echo   Maven: OK
echo.

echo [2/3] Building backend JAR...
cd /d "%~dp0backend"
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [ERROR] Backend build failed.
    pause
    exit /b 1
)

if not exist "%~dp0backend\target\reggie-1.0-SNAPSHOT.jar" (
    echo [ERROR] Build finished but JAR file not found.
    pause
    exit /b 1
)
echo   Backend build: OK
echo.

echo [3/3] Starting all services...

for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr ":8080 " ^| findstr "LISTENING"') do (
    echo   Killing old process on port 8080, PID=%%a
    taskkill /F /PID %%a >nul 2>&1
)

echo   Starting Backend (port 8080)...
start "Backend-8080" /d "%~dp0backend" java -jar target\reggie-1.0-SNAPSHOT.jar --spring.config.location=src/main/resources/application.yml

echo   Waiting for backend...
timeout /t 8 /nobreak >nul

echo   Starting Admin Frontend (port 3000)...
start "Admin-3000" /d "%~dp0frontend\admin" cmd /k "npx vite --port 3000"

echo   Starting Merchant Frontend (port 3001)...
start "Merchant-3001" /d "%~dp0frontend\merchant" cmd /k "npx vite --port 3001"

timeout /t 3 /nobreak >nul

echo.
echo ==========================================
echo   All services started!
echo ------------------------------------------
echo   Admin Frontend:    http://localhost:3000
echo   Merchant Frontend: http://localhost:3001
echo   Backend API:       http://localhost:8080
echo ------------------------------------------
echo   Admin Login: admin / 123456
echo ==========================================
echo.
echo   3 windows opened. Close them to stop.
echo.
pause
