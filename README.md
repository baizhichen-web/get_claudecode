# Claude Code CLI 本地部署方案

通过 CLIProxyAPI 将 Claude Code CLI 连接到本地或其他 API 服务。

## 项目结构

```
.
├── CLIProxyAPI/          # CLIProxyAPI 服务目录
│   ├── cli-proxy-api.exe # 可执行文件
│   ├── config.yaml       # 配置文件
│   └── auth/             # 认证文件目录
├── scripts/              # 脚本目录
│   ├── install.ps1       # 安装脚本
│   └── start-proxy.ps1   # 启动脚本
├── docs/                 # 文档目录
│   └── TROUBLESHOOTING.md # 故障排除指南
└── README.md             # 本文件
```

## 快速开始

### 1. 前置要求

- Windows 系统
- PowerShell 5.0 或更高版本
- Node.js 和 npm（用于安装 Claude Code CLI）
- CLIProxyAPI 可执行文件

### 2. 安装步骤

#### 方式一：使用安装脚本（推荐）

```powershell
# 以管理员身份运行 PowerShell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

安装脚本会自动完成以下操作：
- 检查项目结构
- 创建配置文件
- 配置 Claude Code
- 清理环境变量（避免冲突）

#### 方式二：手动安装

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

3. **清理环境变量**

   删除以下环境变量（如果存在）：
   - `ANTHROPIC_BASE_URL`
   - `ANTHROPIC_API_KEY`
   - `ANTHROPIC_AUTH_TOKEN`

### 3. 启动服务

```powershell
# 方式一：使用启动脚本
.\scripts\start-proxy.ps1

# 方式二：后台运行
.\scripts\start-proxy.ps1 -Background

# 方式三：手动启动
cd CLIProxyAPI
.\cli-proxy-api.exe
```

### 4. 验证连接

```powershell
# 测试 API 服务
Invoke-WebRequest -Uri "http://localhost:8317/v1/models" -Headers @{"Authorization"="Bearer sk-jarvis"}
```

### 5. 运行 Claude Code

```powershell
claude
```

## 配置说明

### API 密钥

默认 API 密钥为 `sk-jarvis`，可以在安装时自定义：

```powershell
.\scripts\install.ps1 -APIKey "your-custom-key"
```

### 端口配置

默认端口为 8317，可以在安装时修改：

```powershell
.\scripts\install.ps1 -Port 8080
```

### 模型别名

CLIProxyAPI 支持将底层模型映射为 Claude Code 兼容的模型名称：

| 别名 | 实际模型 |
|------|----------|
| claude-sonnet-4-6 | coder-model |
| claude-opus-4-6 | coder-model |
| claude-haiku-4-5 | coder-model |

## 故障排除

### 问题：认证冲突

**现象**：显示 `Auth conflict: Both a token and an API key are set`

**解决**：
1. 删除环境变量中的 `ANTHROPIC_AUTH_TOKEN`
2. 确保只使用 `ANTHROPIC_API_KEY`

### 问题：404 错误

**现象**：请求返回 404，路径为 `/v1/v1/messages`

**解决**：
将 `ANTHROPIC_BASE_URL` 从 `http://localhost:8317/v1` 改为 `http://localhost:8317`

### 问题：模型不存在

**现象**：显示 `There's an issue with the selected model`

**解决**：
1. 检查 CLIProxyAPI 配置中的 `oauth-model-alias`
2. 确保模型别名正确映射

更多故障排除信息，请查看 [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

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
      alias: "custom-model-name"
      fork: true
```

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
