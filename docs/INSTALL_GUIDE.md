# Claude Code 安装指南

## 概述

Claude Code 是 Anthropic 提供的官方命令行工具，用于与 Claude 模型进行交互。本指南将帮助您在本地环境中安装并配置 Claude Code，使用 CLIProxyAPI 作为代理服务。

## 系统要求

- **操作系统**: Windows 10/11
- **PowerShell**: 5.0 或更高版本
- **Node.js**: 18.x 或更高版本（用于安装 Claude Code CLI）
- **CLIProxyAPI**: 最新版本

## 安装步骤

### 步骤 1: 准备项目文件

1. **克隆仓库**
   ```powershell
   git clone <仓库地址>
   cd AI_itself
   ```

2. **确保 CLIProxyAPI 可执行文件存在**
   - 确认 `CLIProxyAPI/cli-proxy-api.exe` 或 `CLIProxyAPI/CLIProxyAPI.exe` 文件存在

### 步骤 2: 运行安装脚本

**方法 A: 使用 PowerShell 脚本（推荐）**

1. **以管理员身份运行 PowerShell**
   - 右键点击 PowerShell 图标
   - 选择 "以管理员身份运行"

2. **执行安装脚本**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
   ```

3. **自定义安装参数**（可选）
   ```powershell
   # 自定义 API 密钥和端口
   powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -APIKey "your-custom-key" -Port 8080
   ```

**方法 B: 手动安装**

1. **配置 CLIProxyAPI**
   编辑 `CLIProxyAPI/config.yaml`：
   ```yaml
   port: 8317
   auth-dir: ./auth
   api-keys:
     - "sk-jarvis"
   oauth-model-alias:
     qwen:
       - name: "coder-model"
         alias: "claude-sonnet-4-6"
         fork: true
   ```

2. **配置 Claude Code**
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

3. **安装 Claude Code CLI**
   ```powershell
   npm install -g @anthropic-ai/claude-code
   ```

### 步骤 3: 启动服务

1. **启动 CLIProxyAPI 服务**
   ```powershell
   # 前台运行
   .\scripts\start-proxy.ps1
   
   # 后台运行
   .\scripts\start-proxy.ps1 -Background
   ```

2. **验证服务状态**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8317/v1/models" -Headers @{"Authorization"="Bearer sk-jarvis"}
   ```

### 步骤 4: 运行 Claude Code

```powershell
# 启动 Claude Code
claude

# 指定模型
claude --model claude-opus-4-6

# 执行代码
claude code "print('Hello, World!')"
```

## 通过 Cursor 引导安装

1. **安装 Cursor**
   - 访问 [Cursor](https://cursor.sh) 官网
   - 下载并安装适合您系统的版本

2. **使用 Cursor 引导**
   - 打开 Cursor
   - 输入以下提示：
   ```
   I want to install Claude Code CLI locally with CLIProxyAPI. Please guide me through the installation process using the scripts in the AI_itself project.
   
   Project structure:
   - AI_itself/
     - scripts/install.ps1
     - scripts/start-proxy.ps1
     - CLIProxyAPI/
   
   Please provide step-by-step instructions.
   ```

3. **跟随 Cursor 的指引**
   - Cursor 会根据项目结构提供详细的安装步骤
   - 按照提示执行相应的命令

## 通过 Trae 引导安装

1. **打开 Trae IDE**
   - 确保您已安装并启动 Trae IDE

2. **创建新任务**
   - 点击 "New Task"
   - 输入任务名称："Install Claude Code CLI"

3. **输入任务描述**
   ```
   Install Claude Code CLI using the scripts in the AI_itself project. Follow these steps:
   1. Run the installation script
   2. Start the CLIProxyAPI service
   3. Verify the installation
   4. Test Claude Code
   ```

4. **执行任务**
   - Trae 会自动分析项目结构
   - 提供详细的执行步骤
   - 帮助您完成安装过程

## 故障排除

### 常见问题

1. **认证冲突**
   - **现象**: 显示 "Auth conflict: Both a token and an API key are set"
   - **解决**: 删除 `ANTHROPIC_AUTH_TOKEN` 环境变量

2. **404 错误**
   - **现象**: 请求路径为 `/v1/v1/messages`
   - **解决**: 将 `ANTHROPIC_BASE_URL` 改为 `http://localhost:8317`（去掉 `/v1`）

3. **模型不存在**
   - **现象**: 显示 "There's an issue with the selected model"
   - **解决**: 检查 `config.yaml` 中的模型别名配置

4. **端口被占用**
   - **现象**: 显示 "Only one usage of each socket address"
   - **解决**: 运行 `netstat -ano | findstr :8317` 查看并结束占用端口的进程

### 调试方法

1. **启用调试日志**
   - 在 `config.yaml` 中设置 `debug: true`

2. **查看日志文件**
   - 位置: `CLIProxyAPI/auth/logs/`

3. **测试 API 端点**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8317/v1/models" -Headers @{"Authorization"="Bearer sk-jarvis"}
   ```

## 高级配置

### 多账号支持

在 `config.yaml` 中添加多个 API 密钥：

```yaml
api-keys:
  - "sk-key-1"
  - "sk-key-2"
  - "sk-key-3"
```

### 自定义模型映射

添加更多模型别名：

```yaml
oauth-model-alias:
  qwen:
    - name: "coder-model"
      alias: "claude-sonnet-latest"
      fork: true
    - name: "coder-model"
      alias: "custom-model"
      fork: true
```

## 联系方式

如果您在安装过程中遇到问题，请：
- 查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- 联系项目维护者

---

**祝您使用愉快！** 🎉
