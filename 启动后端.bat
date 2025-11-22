@echo off
chcp 65001 >nul
echo ========================================
echo    启动后端服务 (Spring Boot)
echo ========================================
echo.

cd backend

echo [1/2] 正在启动后端服务...
echo 端口: 8080
echo.

call mvn spring-boot:run

pause

