@echo off
chcp 65001 >nul
echo ========================================
echo    启动前端管理端 (Vue + Vite)
echo ========================================
echo.

cd frontend\admin

echo [1/3] 检查依赖...
if not exist "node_modules" (
    echo 依赖未安装，正在安装...
    call npm install
) else (
    echo 依赖已安装
)

echo.
echo [2/3] 正在启动前端开发服务器...
echo 端口: 3000
echo.

call npm run dev

pause

