## DAO-CLI v1.1.6

### 修复
- **工具路径页换行**：Shift+Enter / Ctrl+J 可正常换行（Enter 单独按下才开始检查）
- **智谱 ZAI 视觉 MCP（Windows）**：stdio 启动改为 `cmd /c npx …`，修复 `MCP stdio spawn failed`
- MiniMax MCP 在 Windows 上同样使用 `cmd /c uvx …` 包装

### 智谱 MCP 使用说明
- 需要 **Node.js 18+**（`node -v`、`npx -v` 可用）
- 在 **系统设置 → 图片识别 → 智谱识图 MCP** 填写 GLM Coding Plan API Key
- 保存后运行 **`/mcp reload`**
- 官方文档：https://docs.bigmodel.cn/cn/coding-plan/mcp/vision-mcp-server

### 安装

```powershell
irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex
```
