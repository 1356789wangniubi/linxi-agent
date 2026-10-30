# 密钥与隐私

## 智谱 API key 怎么存

- 存放在 `secrets/zhipu.key`；
- 使用 **Windows DPAPI（CurrentUser）** 加密；
- 只有当前 Windows 用户能解密；
- 源码、`.bat`、文档里都**没有明文 key**。

设置/轮换：

```powershell
python -m fishflow.secret_setup
```

输入时终端不回显。保存后可以用：

```powershell
python -m fishflow.llm_check
```

检查连通性，不会打印 key。

## 启动智谱版

双击 **`chat_zhipu.bat`**，或：

```powershell
$env:FISHFLOW_LLM_URL="https://open.bigmodel.cn/api/paas/v4/chat/completions"
$env:FISHFLOW_LLM_MODEL="glm-4-flash"
python -m fishflow.chat_server
```

`chat_zhipu.bat` 只设置 URL/模型，key 由 Python 从 DPAPI 读取。

## 注意

- 不要提交/打包 `secrets/`；
- 不要把 `secrets/zhipu.key` 发给别人；
- 如果 key 曾经出现在聊天记录、日志、截图中，建议去智谱控制台**吊销并重建**；
- 使用智谱时，用户问题会发送到智谱服务器，不再是纯本地；
- 领域工具的数字/图仍由本地 Python 产生，LLM 只做路由和通用问答。

## 删除本地密钥

```powershell
Remove-Item secrets\zhipu.key
```

删除后 `chat_zhipu.bat` 会提示没有密钥，聊天仍可用规则模式。
