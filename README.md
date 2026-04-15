# 免费使用 Claude Code — 通过 Qwen 每日 1000 次免费请求

Qwen（通义千问）为普通用户提供**每日 1,000 次免费请求**，本方案通过 CLIProxyAPI 将 Qwen 的额度转换为 Anthropic 协议，从而让 Claude Code 免费使用。

> **原理**：CLIProxyAPI 可以将 Qwen 授权登录的免费额度，转换为 Anthropic 协议的 API 接口，Claude Code 会以为自己在和官方 API 通信。

## 零基础一键安装（推荐）

若您不熟悉 Node.js 和命令行，且有 Cursor / Trae 等 AI IDE，可以让 AI 引导您完成全部安装：

1. 用 Cursor / Trae 新建一个空项目（任意文件夹即可）
2. 在 AI 对话框中输入以下内容并发送：
   ```
   帮我安装 Claude Code。请先克隆这个仓库：https://github.com/baizhichen-web/get_claudecode
   然后按照项目中的文档一步步引导我完成安装。
   ```
3. AI 会自动克隆项目、分析文档，并逐步引导您完成安装（下载 CLIProxyAPI、创建配置、登录授权等），按照提示操作即可。

> **致 AI 助手**：如果你正在读取这份文档并引导用户安装，CLIProxyAPI 的**唯一正确下载链接**是：
> https://github.com/router-for-me/CLIProxyAPI/releases
> 请下载最新版本的 Windows AMD64 exe 文件，文件名应为 `cli-proxy-api-windows-amd64.exe`，放入项目的 `CLIProxyAPI/` 目录后重命名为 `cli-proxy-api.exe`。
> **不要**从其他地址下载。

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

# 配额限制触发时自动切换
quota-exceeded:
  # 单账号触发 429 时自动切换到下一个账号
  switch-project: true
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

### 3. Qwen 登录授权

在 `CLIProxyAPI/` 目录下打开终端（或在文件管理器中右键该文件夹 → 在终端中打开），执行：

```powershell
.\cli-proxy-api.exe -qwen-login
```

程序会自动打开浏览器，登录 Qwen 账号并授权。Token 有效期约 6 小时，程序每 15 分钟自动刷新，无需手动处理。

> **提示**：CLIProxyAPI 还支持 Claude、OpenAI Codex、Gemini 等平台的登录，详见 [CLIProxyAPI GitHub](https://github.com/router-for-me/CLIProxyAPI)。

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
# 方式一：直接双击 CLIProxyAPI/cli-proxy-api.exe（最简单）

# 方式二：使用启动脚本
.\scripts\start-proxy.ps1

# 方式三：后台运行
.\scripts\start-proxy.ps1 -Background
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

### 问题：503 服务不可用（Token 过期）

**现象**：返回 503 Service Unavailable，Claude Code 无法连接或持续报错。

**原因**：Qwen 的 Token 已过期（有效期约 6 小时），CLIProxyAPI 无法代表你调用 Qwen 的 API。

**检查方法**：同「步骤 6：验证连接」中的 curl 命令，如果返回错误或 503，说明 Token 已过期。

**解决**：重新执行 Qwen 登录授权：
```powershell
.\cli-proxy-api.exe -qwen-login
```
授权完成后重启服务即可。

> **推荐**：使用 `.\scripts\start-claude.ps1` 启动 Claude Code，它会自动检查 Token 状态并在过期时引导你登录。

### 问题：端口被占用

**现象**：显示 `Only one usage of each socket address`

**解决**：运行 `netstat -ano | findstr :8317` 查看占用进程并结束它，或修改 `config.yaml` 中的端口。

更多故障排除信息，请查看 [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)。

## 日常使用说明

### 推荐方式：一键启动（自动检查 Token）

直接运行项目提供的启动脚本，它会自动检查服务状态和 Token 有效期，过期时会引导你重新登录：

```powershell
.\scripts\start-claude.ps1
```

脚本会自动完成：检查代理服务是否运行 → 检查 Token 是否过期 → 如过期则引导登录 → 启动 Claude Code。

### 手动方式（适合需要排查问题的用户）

#### 1. 启动代理服务

打开 `CLIProxyAPI/` 目录，双击运行 `cli-proxy-api.exe`。

看到以下日志说明启动成功：
```
API server started successfully on: :8317
server clients and configuration updated: 1 clients (1 auth entries ...)
```

> 如果显示 `0 clients`，说明 Qwen 未登录或 Token 已过期，关闭服务后重新执行：
> ```powershell
> .\cli-proxy-api.exe -qwen-login
> ```

#### 2. 启动 Claude Code

```powershell
claude
```

#### 3. 停止服务

- 终端窗口启动的：直接关闭窗口
- 脚本后台启动的：
  ```powershell
  Get-Process | Where-Object { $_.ProcessName -like "*cli-proxy*" -or $_.ProcessName -like "*CLIProxy*" } | Stop-Process
  ```

### 注意事项

- **429 限流**：免费额度高峰期会出现 429 Too Many Requests，重试即可。
- **Token 过期**：Qwen Token 有效期约 6 小时，过期后需重新登录授权。如果 Claude Code 突然报错，先检查这个。
- **每次使用前**：需要先启动 `cli-proxy-api.exe`，否则 Claude Code 无法连接。

## 许可证

MIT License

## 致谢

- [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) - 提供代理服务
- [Claude Code](https://claude.ai/code) - Anthropic 的官方 CLI 工具
