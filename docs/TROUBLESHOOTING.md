# 故障排除指南

## 常见问题

### 1. 认证冲突

#### 现象
```
‼Auth conflict: Both a token (ANTHROPIC_AUTH_TOKEN) and an API key (ANTHROPIC_API_KEY) are set.
```

#### 原因
同时设置了 `ANTHROPIC_AUTH_TOKEN` 和 `ANTHROPIC_API_KEY` 环境变量或配置文件项。

#### 解决步骤

1. **检查环境变量**
   ```powershell
   Get-ChildItem Env:ANTHROPIC*
   ```

2. **删除环境变量**
   ```powershell
   [Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', $null, 'User')
   [Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', $null, 'Process')
   ```

3. **检查配置文件**
   打开 `C:\Users\<用户名>\.claude\settings.json`，确保只包含：
   ```json
   {
     "env": {
       "ANTHROPIC_BASE_URL": "http://localhost:8317",
       "ANTHROPIC_API_KEY": "sk-jarvis"
     }
   }
   ```

### 2. 404 错误 - 路径问题

#### 现象
日志显示请求路径为 `/v1/v1/messages`，返回 404 错误。

#### 原因
`ANTHROPIC_BASE_URL` 设置错误。Claude Code CLI 会自动添加 `/v1` 路径。

#### 解决
将 `ANTHROPIC_BASE_URL` 从：
```
http://localhost:8317/v1  ❌ 错误
```
改为：
```
http://localhost:8317     ✓ 正确
```

### 3. 模型不存在

#### 现象
```
There's an issue with the selected model (claude-sonnet-4-6). 
It may not exist or you may not have access to it.
```

#### 原因
CLIProxyAPI 配置中缺少模型别名映射。

#### 解决
在 `config.yaml` 中添加模型别名：
```yaml
oauth-model-alias:
  qwen:
    - name: "coder-model"
      alias: "claude-sonnet-4-6"
      fork: true
```

### 4. 端口被占用

#### 现象
```
listen tcp :8317: bind: Only one usage of each socket address
```

#### 解决

1. **查找占用端口的进程**
   ```powershell
   netstat -ano | findstr :8317
   ```

2. **结束进程**
   ```powershell
   taskkill /PID <进程ID> /F
   ```

3. **或使用启动脚本自动处理**
   ```powershell
   .\scripts\start-proxy.ps1
   ```

### 5. 连接被拒绝

#### 现象
```
Failed to connect to localhost:8317: ECONNREFUSED
```

#### 原因
CLIProxyAPI 服务未启动。

#### 解决
1. 启动服务：
   ```powershell
   .\scripts\start-proxy.ps1
   ```

2. 验证服务状态：
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8317/v1/models" -Headers @{"Authorization"="Bearer sk-jarvis"}
   ```

### 6. API 密钥错误

#### 现象
```
401 Unauthorized
```

#### 解决
1. 检查 `config.yaml` 中的 `api-keys`
2. 检查 Claude Code 配置中的 `ANTHROPIC_API_KEY`
3. 确保两者匹配

## 调试方法

### 启用调试日志

在 `config.yaml` 中设置：
```yaml
debug: true
```

### 查看日志文件

日志位置：`CLIProxyAPI/auth/logs/`

```powershell
# 查看最新日志
Get-ChildItem CLIProxyAPI/auth/logs/ | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content
```

### 测试 API 端点

```powershell
# 测试模型列表
Invoke-WebRequest -Uri "http://localhost:8317/v1/models" -Headers @{"Authorization"="Bearer sk-jarvis"} -UseBasicParsing

# 测试聊天完成
$body = @{
    model = "claude-sonnet-4-6"
    messages = @(@{role = "user"; content = "Hello"})
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8317/v1/chat/completions" -Method POST -Headers @{"Authorization"="Bearer sk-jarvis"; "Content-Type"="application/json"} -Body $body -UseBasicParsing
```

### 7. 429 限流（Too Many Requests）

#### 现象
API 返回 `429 Too Many Requests` 或 `Too busy`

#### 原因
免费额度或平台限流。这是正常现象，尤其是 Qwen 等平台的免费模型。

#### 解决
- **重试即可**：等待几秒后重新请求
- **配置多账号**：在 `config.yaml` 中设置 `quota-exceeded.switch-project: true`，程序会自动切换账号
- **避开高峰**：工作日晚间通常是使用高峰期

## 联系支持

如果以上方法无法解决问题，请：
1. 收集日志文件
2. 记录错误信息
3. 提交 Issue 或联系支持
