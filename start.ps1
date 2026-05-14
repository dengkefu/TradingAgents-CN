Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TradingAgents-CN 后端启动" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 激活虚拟环境
$venvActivate = Join-Path $PSScriptRoot "venv\Scripts\Activate.ps1"
& $venvActivate

# 启动后端
Write-Host "🚀 启动后端服务..." -ForegroundColor Green
python -m app

pause
