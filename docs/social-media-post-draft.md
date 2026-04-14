很多人问怎么开始 AI coding，一直卡在两个问题：太贵，以及不会搭。

最近看到 Qwen（通义千问）给普通用户每天 1000 次免费请求，我就在想，能不能把这个免费额度拿来驱动 Claude Code？

研究了一下还真行，而且比想象中简单。

原理不复杂：
Qwen 的免费额度 + CLIProxyAPI 做协议转换 → Claude Code 就能正常调用。
简单说就是把 Qwen 的额度转换成 Anthropic 协议的 API，Claude Code 会以为自己在和官方 API 通信。

---

准备的东西就两个：
- Qwen 账号（免费，每天 1000 次请求）
- CLIProxyAPI（一个开源小工具）

---

步骤来了：

1 下载 CLIProxyAPI
去 GitHub 搜 CLIProxyAPI，到 Releases 页面下载 Windows AMD 的 exe 文件。
放到一个文件夹里，比如 E:\2api\，文件名是 cli-proxy-api.exe。
在同一目录下创建 CLIProxyAPI 文件夹。

2 写配置文件
在 CLIProxyAPI 文件夹下创建 config.yaml，内容如下：

port: 8317
auth-dir: ./auth
api-keys:
  - "sk-jarvis"
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

3 Qwen 登录授权
在 cli-proxy-api.exe 所在目录打开终端，输入：
.\cli-proxy-api.exe -qwen-login

会自动弹浏览器，登录 Qwen 账号授权就行。
Token 有效期约 6 小时，程序每 15 分钟自动刷新，不用管。

4 配置 Claude Code
在 C:\Users\你的用户名\.claude\ 下创建或编辑 settings.json：

{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:8317",
    "ANTHROPIC_API_KEY": "sk-jarvis"
  },
  "model": "claude-sonnet-4-6"
}

注意：只设置 ANTHROPIC_API_KEY，不要同时设置 ANTHROPIC_AUTH_TOKEN，否则会报认证冲突。

5 启动服务
双击 cli-proxy-api.exe 就行。
看到这两行就是成功了：
API server started successfully on: :8317
server clients and configuration updated: 1 clients (1 auth entries ...)

6 验证一下
在终端输入：
curl http://localhost:8317/v1/models -H "x-api-key: sk-jarvis"
正常会返回 coder-model，说明通了。

7 用 Claude Code
终端输入 claude 就完事了。
会看到熟悉的交互式界面，可以写代码、改 bug、建项目。

---

注意事项：

- 429 太忙了：免费高峰期会出现，等几秒重试就好
- Token 过期：约 6 小时，过期后重新执行第 3 步登录
- 每次用之前先启动 cli-proxy-api.exe，不然连不上

---

完整的项目和脚本我放在 GitHub 上了：
https://github.com/baizhichen-web/get_claudecode

如果你连命令行都不想碰，用 Cursor 或 Trae 打开这个项目，在 AI 对话框输入 "Help me install Claude Code"，AI 会一步步引导你完成。
