## DAO-CLI v1.1.7

### 修复
- **`dao update` 无法更新**：SHA256 清单去掉 UTF-8 BOM，解析器自动忽略 BOM
- **工具路径页换行**：Shift+Enter / Ctrl+J 正常换行
- **智谱 ZAI MCP（Windows）**：`cmd /c npx …` 修复 spawn 失败

### 新增
- 智谱 / MiniMax 识图**小白教程**（系统设置 + `/vision zhipu` / `/vision minimax`）
- 引导页、工具路径、识图说明全面改为易懂中文

### 安装

```powershell
irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex
```

升级后若已配置智谱/MiniMax Key，请运行 `/mcp reload`。
