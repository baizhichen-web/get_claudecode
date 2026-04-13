# Claude Code CLI 本地代理启动脚本
# 用于启动 CLIProxyAPI 服务

param(
    [switch]$Background
)

$ErrorActionPreference = "Stop"

# 获取项目根目录
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$CLIProxyAPIPath = Join-Path $ProjectRoot "CLIProxyAPI"
$ExecutablePath = Join-Path $CLIProxyAPIPath "cli-proxy-api.exe"

# 检查可执行文件
if (-not (Test-Path $ExecutablePath)) {
    $ExecutablePath = Join-Path $CLIProxyAPIPath "CLIProxyAPI.exe"
    if (-not (Test-Path $ExecutablePath)) {
        Write-Error "找不到 CLIProxyAPI 可执行文件"
        exit 1
    }
}

# 检查端口是否被占用
$port = 8317
$portInUse = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Warning "端口 $port 已被占用，尝试关闭现有进程..."
    Get-Process | Where-Object { $_.ProcessName -like "*cli-proxy*" -or $_.ProcessName -like "*CLIProxy*" } | Stop-Process -Force
    Start-Sleep -Seconds 2
}

Write-Host "正在启动 CLIProxyAPI 服务..." -ForegroundColor Cyan
Write-Host "工作目录: $CLIProxyAPIPath" -ForegroundColor Gray
Write-Host ""

# 切换到工作目录
Set-Location $CLIProxyAPIPath

if ($Background) {
    # 后台启动
    $process = Start-Process -FilePath $ExecutablePath -WorkingDirectory $CLIProxyAPIPath -WindowStyle Hidden -PassThru
    Write-Host "✓ 服务已在后台启动 (PID: $($process.Id))" -ForegroundColor Green
    Write-Host ""
    Write-Host "服务地址: http://localhost:$port" -ForegroundColor Yellow
    Write-Host "测试连接: Invoke-WebRequest -Uri " -NoNewline
    Write-Host "http://localhost:$port/v1/models" -ForegroundColor Cyan
} else {
    # 前台启动
    Write-Host "按 Ctrl+C 停止服务" -ForegroundColor Yellow
    Write-Host ""
    & $ExecutablePath
}
