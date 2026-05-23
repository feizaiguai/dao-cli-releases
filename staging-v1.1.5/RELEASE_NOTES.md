## DAO-CLI v1.1.5

### 智谱识图改为 GLM Coding Plan MCP
- **移除** 旧方案：智谱 `glm-4v` + `image_analyze` + `[providers.zhipu]` 视觉 Key
- **新增** 智谱官方视觉理解 MCP：`npx @z_ai/mcp-server@latest`
- 填写 **GLM Coding Plan 订阅 API Key** 即可，自动写入 `~/.dao-cli/mcp.json`
- 支持 `image_analysis`、OCR、UI 截图转代码、错误截图诊断等工具
- 配置入口：系统设置 → 智谱识图 MCP，或首次引导页
- 官方文档：https://docs.bigmodel.cn/cn/coding-plan/mcp/vision-mcp-server

### 安装

```powershell
irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex
```

保存后请运行 `/mcp reload` 加载 MCP。
