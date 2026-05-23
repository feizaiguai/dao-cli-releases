## DAO-CLI v1.1.4

### 系统设置 & 图片识别
- **系统设置**（`/config`）：中文界面，新增「图片识别」分区
- **OpenAI 识图教程**：系统设置内「OpenAI 识图教程」或 `/vision openai`
- **粘贴一次永久保存**：accessToken 写入 config + credentials + 系统密钥库；支持整段 session JSON 自动提取
- 首次引导页增加 OpenAI 识图字段，无需手改 config.toml

### 安装

```powershell
irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex
```
