# Claude Code CLI 本地部署安装脚本
# 适用于 Windows 系统

param(
    [string]$APIKey = "sk-jarvis",
    [int]$Port = 8317,
    [switch]$SkipClaudeCodeInstall
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Claude Code CLI 本地部署安装程序" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 获取项目根目录
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$CLIProxyAPIPath = Join-Path $ProjectRoot "CLIProxyAPI"

Write-Host "[1/5] 检查项目结构..." -ForegroundColor Yellow

# 检查 CLIProxyAPI 目录
if (-not (Test-Path $CLIProxyAPIPath)) {
    Write-Error "CLIProxyAPI 目录不存在: $CLIProxyAPIPath"
    exit 1
}

# 检查可执行文件
$ExecutablePath = Join-Path $CLIProxyAPIPath "cli-proxy-api.exe"
if (-not (Test-Path $ExecutablePath)) {
    $ExecutablePath = Join-Path $CLIProxyAPIPath "CLIProxyAPI.exe"
    if (-not (Test-Path $ExecutablePath)) {
        Write-Error "找不到 CLIProxyAPI 可执行文件"
        exit 1
    }
}

Write-Host "  找到 CLIProxyAPI 可执行文件" -ForegroundColor Green

# 创建配置文件
Write-Host ""
Write-Host "[2/5] 创建配置文件..." -ForegroundColor Yellow

$configContent = @"
port: $Port
auth-dir: ./auth
api-keys:
  - "$APIKey"
debug: false
request-retry: 3
quota-exceeded:
  switch-project: true
  switch-preview-model: true
oauth-model-alias:
  qwen:
    - name: "coder-model"
      alias: "claude-sonnet-4-6"
      fork: true
    - name: "coder-model"
      alias: "claude-opus-4-6"
      fork: true
    - name: "coder-model"
      alias: "claude-haiku-4-5"
      fork: true
"@

$configPath = Join-Path $CLIProxyAPIPath "config.yaml"
$configContent | Out-File -FilePath $configPath -Encoding UTF8
Write-Host "  配置文件已创建" -ForegroundColor Green

# 配置 Claude Code
Write-Host ""
Write-Host "[3/5] 配置 Claude Code..." -ForegroundColor Yellow

$ClaudeConfigDir = "$env:USERPROFILE\.claude"
$ClaudeConfigFile = "$ClaudeConfigDir\settings.json"

if (-not (Test-Path $ClaudeConfigDir)) {
    New-Item -ItemType Directory -Path $ClaudeConfigDir -Force | Out-Null
}

$claudeConfig = @{
    env = @{
        ANTHROPIC_BASE_URL = "http://localhost:$Port"
        ANTHROPIC_API_KEY = $APIKey
    }
    model = "claude-sonnet-4-6"
}

$claudeConfig | ConvertTo-Json -Depth 3 | Out-File -FilePath $ClaudeConfigFile -Encoding UTF8
Write-Host "  Claude Code 配置已更新" -ForegroundColor Green

# 清理环境变量
Write-Host ""
Write-Host "[4/5] 清理环境变量..." -ForegroundColor Yellow

@('ANTHROPIC_BASE_URL', 'ANTHROPIC_API_KEY', 'ANTHROPIC_AUTH_TOKEN') | ForEach-Object {
    [Environment]::SetEnvironmentVariable($_, $null, 'User')
}
Write-Host "  环境变量已清理" -ForegroundColor Green

# 检查 Claude Code CLI
if (-not $SkipClaudeCodeInstall) {
    Write-Host ""
    Write-Host "[5/5] 检查 Claude Code CLI..." -ForegroundColor Yellow
    
    $claudeCheck = Get-Command claude -ErrorAction SilentlyContinue
    if ($claudeCheck) {
        $claudeVersion = & claude --version 2>$null
        Write-Host "  Claude Code CLI 已安装: $claudeVersion" -ForegroundColor Green
    } else {
        Write-Host "  请手动安装 Claude Code CLI:" -ForegroundColor Yellow
        Write-Host "    npm install -g @anthropic-ai/claude-code" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  安装完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "  1. 启动服务: .\scripts\start-proxy.ps1" -ForegroundColor White
Write-Host "  2. 运行 Claude Code: claude" -ForegroundColor White
Write-Host ""
