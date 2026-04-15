# Claude Code 启动脚本（带 Token 健康检查）
# 用法: .\scripts\start-claude.ps1

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$CLIProxyAPIPath = Join-Path $ProjectRoot "CLIProxyAPI"
$configPath = Join-Path $CLIProxyAPIPath "config.yaml"

# 从配置文件读取端口
$port = 8317
if (Test-Path $configPath) {
    try {
        $configContent = Get-Content $configPath -Raw
        $portMatch = [regex]::Match($configContent, '(?m)^port:\s*(\d+)')
        if ($portMatch.Success) {
            $port = [int]$portMatch.Groups[1].Value
        }
    } catch {
        # 使用默认端口
    }
}

$apiUrl = "http://localhost:$port/v1/models"

# 检查代理服务是否运行
$tokenExpired = $false
$proxyRunning = $true
try {
    $null = Invoke-WebRequest -Uri $apiUrl -Headers @{"x-api-key" = "sk-jarvis"} -UseBasicParsing -TimeoutSec 5
} catch {
    $statusCode = $_.Exception.Response.StatusCode
    if ($statusCode -and ([int]$statusCode -eq 503)) {
        # 服务运行但 Token 过期
        $tokenExpired = $true
    } else {
        # 服务未运行或无法连接
        $proxyRunning = $false
    }
}

if (-not $proxyRunning) {
    Write-Host "" -NoNewline
    Write-Host "[!] CLIProxyAPI 服务未运行" -ForegroundColor Red
    Write-Host "    请先启动代理服务：" -ForegroundColor Yellow
    Write-Host "    .\scripts\start-proxy.ps1" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

if ($tokenExpired) {
    Write-Host "" -NoNewline
    Write-Host "[!] Qwen Token 已过期 (503)" -ForegroundColor Red
    Write-Host "    需要重新登录授权。" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    是否现在执行 Qwen 登录？(Y/N): " -ForegroundColor Yellow -NoNewline
    $answer = Read-Host
    if ($answer -match '^[Yy]') {
        Set-Location $CLIProxyAPIPath
        & .\cli-proxy-api.exe -qwen-login
        Write-Host ""
        Write-Host "    登录完成！重新检查 Token 状态..." -ForegroundColor Green
        Start-Sleep -Seconds 2
        # 再次检查
        try {
            $response = Invoke-WebRequest -Uri $apiUrl -Headers @{"x-api-key" = "sk-jarvis"} -UseBasicParsing -TimeoutSec 5
            Write-Host "    Token 状态正常，可以启动 Claude Code！" -ForegroundColor Green
        } catch {
            Write-Host "    Token 仍然无效，请稍后重试。" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "    已取消。请手动执行: .\CLIProxyAPI\cli-proxy-api.exe -qwen-login" -ForegroundColor Gray
        exit 1
    }
}

Write-Host "[✓] 代理服务正常，启动 Claude Code..." -ForegroundColor Green
Write-Host ""

# 启动 Claude Code
claude @args
