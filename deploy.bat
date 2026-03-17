@echo off
chcp 65001 >nul
echo ==========================================
echo   校园餐饮系统 - Docker 全镜像部署
echo ==========================================
echo.

echo [1/4] 停止旧容器...
docker-compose down
echo.

echo [2/4] 构建所有镜像（含后端 Maven 构建 + 前端 npm 构建）...
docker-compose build --no-cache
echo.

echo [3/4] 启动所有服务...
docker-compose up -d
echo.

echo [4/4] 等待服务启动...
echo   正在等待 MySQL 健康检查...
timeout /t 30 /nobreak >nul

echo.
echo ==========================================
echo   部署完成！访问地址：
echo ------------------------------------------
echo   管理端前端:   http://localhost:3000
echo   商家端前端:   http://localhost:3001
echo   后端 API:     http://localhost:8080
echo   MySQL:        localhost:3306
echo   Redis:        localhost:6379
echo ==========================================
echo.
echo   管理端登录账号: admin / 123456
echo ==========================================
echo.

echo 查看容器状态:
docker-compose ps
echo.

echo 查看后端日志（按 Ctrl+C 退出）:
docker-compose logs -f backend
