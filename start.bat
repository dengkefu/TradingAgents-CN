@echo off
chcp 65001 >nul
echo ========================================
echo   TradingAgents-CN 启动脚本
echo ========================================

:: 激活虚拟环境
call venv\Scripts\activate

:: 启动后端
echo 🚀 启动后端服务...
python -m app

pause
