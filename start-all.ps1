Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TradingAgents-CN 启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 激活虚拟环境
$venvActivate = Join-Path $PSScriptRoot "venv\Scripts\Activate.ps1"
& $venvActivate

# 启动后端（新窗口）
Write-Host "🚀 启动后端服务..." -ForegroundColor Green
$backendIcon = Start-Process powershell -ArgumentList "-NoExit", "-Command", "python -m app; pause" -PassThru

Start-Sleep -Seconds 3

# 启动前端（新窗口）
Write-Host "🌐 启动前端服务..." -ForegroundColor Green
Push-Location frontend
$frontendIcon = Start-Process powershell -ArgumentList "-NoExit", "-Command", "yarn dev; pause" -PassThru
Pop-Location

Write-Host "`n✅ 后端和前端已启动！" -ForegroundColor Green
Write-Host "  后端地址: http://localhost:8000" -ForegroundColor Yellow
Write-Host "  前端地址: http://localhost:3000" -ForegroundColor Yellow
Write-Host "`n  关闭对应的窗口即可停止服务。`n" -ForegroundColor Gray
Read-Host "按回车退出"
