@echo off
chcp 65001 >nul
echo ========================================
echo   TradingAgents-CN 启动脚本
echo ========================================

:: 激活虚拟环境
call venv\Scripts\activate

:: 启动后端（后台运行，不阻塞）
echo 🚀 启动后端服务...
start "TradingAgents-Backend" cmd /c "python -m app && pause"

:: 等后端启动几秒
timeout /t 3 /nobreak >nul

:: 启动前端
echo 🌐 启动前端服务...
cd frontend
start "TradingAgents-Frontend" cmd /c "yarn dev && pause"
cd ..

echo ✅ 后端和前端已启动！
echo   后端地址: http://localhost:8000
echo   前端地址: http://localhost:3000
echo.
echo   关闭窗口不会停止服务，请在任务管理器中结束。
echo.
pause
