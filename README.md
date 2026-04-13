# Claude Code CLI 本地部署方案

通过 CLIProxyAPI 将 Claude Code CLI 连接到各大平台（Qwen、Claude、Gemini 等）的免费额度。

> **原理**：CLIProxyAPI 可以将各平台授权登录的额度，转换为 OpenAI / Anthropic / Google 三种协议的 API，从而让 Claude Code 等工具调用。

## 快速开始

### 1. 获取 CLIProxyAPI

访问 [CLIProxyAPI GitHub Releases](https://github.com/router-for-me/CLIProxyAPI/releases)，下载最新版本的 Windows AMD EXE 程序。

将下载的 `cli-proxy-api.exe` 放入项目根目录下的 `CLIProxyAPI/` 文件夹中（如果没有该目录，请先创建）：

```
claude-code-deployment/
└── CLIProxyAPI/
    └── cli-proxy-api.exe    ← 放这里
```

### 2. 创建配置文件

在 `CLIProxyAPI/` 目录下创建 `config.yaml`，内容如下：

```yaml
# API 服务端口
port: 8317

# 授权文件目录（相对路径，相对于 exe 所在目录）
auth-dir: ./auth

# 客户端访问 API 时使用的 Key（自定义，用于鉴权）
api-keys:
  - "sk-jarvis"

# 是否开启 Debug 日志
debug: false

# 遇到 403/408/500/502/503/504 时自动重试次数
request-retry: 3

# 多账号配额轮询
quota-exceeded:
  # 单账号触发 429 时自动切换到下一个账号
  switch-project: true
  # Gemini 正式版配额用完后自动切换 Preview 模型
  switch-preview-model: true

# 模型别名映射（将底层模型映射为 Claude Code 兼容名称）
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
```

### 3. 登录授权

在 `CLIProxyAPI/` 目录下打开终端，执行对应平台的登录命令：

```powershell
# Qwen 授权
.\cli-proxy-api.exe -qwen-login

# Claude Code 授权
.\cli-proxy-api.exe -claude-login

# OpenAI Codex 授权
.\cli-proxy-api.exe -codex-login

# Gemini CLI 授权
.\cli-proxy-api.exe -login
```

执行后会自动打开浏览器，按照提示登录并授权即可。Token 有效期约 6 小时，程序每 15 分钟自动刷新，无需手动处理。

### 4. 配置 Claude Code

创建或编辑 `C:\Users\<用户名>\.claude\settings.json`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:8317",
    "ANTHROPIC_API_KEY": "sk-jarvis"
  },
  "model": "claude-sonnet-4-6"
}
```

> **注意**：确保只使用 `ANTHROPIC_API_KEY`，不要同时设置 `ANTHROPIC_AUTH_TOKEN`，否则会报认证冲突。

### 5. 启动服务

```powershell
# 方式一：使用启动脚本（推荐）
.\scripts\start-proxy.ps1

# 方式二：后台运行
.\scripts\start-proxy.ps1 -Background

# 方式三：手动启动
cd CLIProxyAPI
.\cli-proxy-api.exe
```

启动成功后会看到以下日志：
```
API server started successfully on: :8317
server clients and configuration updated: 1 clients (1 auth entries ...)
```

### 6. 验证连接

```powershell
# 测试 API 服务
curl http://localhost:8317/v1/models -H "x-api-key: sk-jarvis"
```

正常返回如下：
```json
{"data":[{"created":1771171200,"id":"coder-model","object":"model","owned_by":"qwen"}],"object":"list"}
```

> **遇到 429（Too Many Requests）说明服务太忙，重试即可，这是正常现象。**

### 7. 运行 Claude Code

```powershell
# 启动 Claude Code
claude

# 指定模型
claude --model claude-opus-4-6
```

## 安装脚本（可选）

项目提供了自动化安装脚本，适合快速部署。

### 使用安装脚本

```powershell
# 以管理员身份运行 PowerShell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

安装脚本会自动完成以下操作：
- 检查项目结构（CLIProxyAPI/ 目录和可执行文件）
- 创建配置文件
- 配置 Claude Code
- 清理环境变量（避免冲突）
- 检查 Claude Code CLI 是否已安装

### 自定义参数

```powershell
# 自定义 API 密钥和端口
.\scripts\install.ps1 -APIKey "your-custom-key" -Port 8080

# 跳过 Claude Code CLI 检查
.\scripts\install.ps1 -SkipClaudeCodeInstall
```

> **注意**：脚本不会自动下载 CLIProxyAPI 可执行文件，需要先手动下载并放入 `CLIProxyAPI/` 目录。

## 故障排除

### 问题：认证冲突

**现象**：显示 `Auth conflict: Both a token and an API key are set`

**解决**：删除环境变量中的 `ANTHROPIC_AUTH_TOKEN`，确保只使用 `ANTHROPIC_API_KEY`。

### 问题：404 错误

**现象**：请求返回 404，路径为 `/v1/v1/messages`

**解决**：将 `ANTHROPIC_BASE_URL` 从 `http://localhost:8317/v1` 改为 `http://localhost:8317`。Claude Code 会自动添加 `/v1` 路径。

### 问题：模型不存在

**现象**：显示 `There's an issue with the selected model`

**解决**：检查 `config.yaml` 中的 `oauth-model-alias` 配置，确保模型别名正确映射。

### 问题：429 限流

**现象**：返回 429 Too Many Requests

**解决**：服务太忙，重试即可。如果配置了多账号，程序会自动切换到下一个账号。

### 问题：端口被占用

**现象**：显示 `Only one usage of each socket address`

**解决**：运行 `netstat -ano | findstr :8317` 查看占用进程并结束它，或修改 `config.yaml` 中的端口。

更多故障排除信息，请查看 [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)。

## 更新日志

### v1.0.0
- 初始版本
- 支持 Windows 系统
- 提供安装脚本和文档

## 许可证

MIT License

## 致谢

- [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) - 提供代理服务
- [Claude Code](https://claude.ai/code) - Anthropic 的官方 CLI 工具
