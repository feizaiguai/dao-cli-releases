# DAO-CLI v1.1.10

> 紧急修复：智谱（ZAI）与 MiniMax 视觉 MCP 「initialization timed out」

## 修复

- **ZAI / MiniMax MCP 启动超时**
  - 现象：终端顶部红字 `Failed to connect MCP server 'ZAI': MCP server 'ZAI' initialization timed out: deadline has elapsed`
  - 根因：默认 `connect_timeout = 10s`，而 `npx -y @z_ai/mcp-server@latest`、`uvx minimax-coding-plan-mcp` **首次运行需要从远端拉取数十 MB 的包**，握手在下载完成前就被掐断
  - 修法：
    1. `zhipu_mcp_config.rs` / `minimax_mcp_config.rs` upsert 时显式写入 `connect_timeout = 120`
    2. `mcp.rs` 在 spawn 阶段自动识别 `npx / uvx / pnpm / yarn`（含 Windows `cmd /c <launcher>` 包装），把 `connect_timeout` 兜底拉到 120 秒
  - **老用户无需手动改 `~/.dao-cli/mcp.json`**，下次启动 dao 即自动生效

## 工程

- 新增 `mcp_stdio_windows::cold_fetch_min_connect_timeout()` 工具函数（npx / uvx / cmd-wrapped 路径全覆盖）+ 6 个新单测
- 工作区全量测试：**3119 passed / 0 failed / 3 ignored**
- 发布清单：BOM-free UTF-8（继续保持 v1.1.7 后的格式）

## 安装

PowerShell：

```powershell
irm https://github.com/feizaiguai/dao-cli-releases/releases/download/v1.1.10/install.ps1 | iex
```

或显式指定版本：

```powershell
& ([scriptblock]::Create((irm https://github.com/feizaiguai/dao-cli-releases/releases/download/v1.1.10/install.ps1))) -Version 1.1.10
```

升级老版本：

```powershell
dao update
```

## 校验

```text
9a3f20c76a8a187b7822c23a59931c950b3ded6ea87ab1c0a127de58289074f3  dao-windows-x64.exe
3d98b4fd8dc591a8c4f6c526b42e3018343304b2c8ba6e5c43d1cd825a314257  dao-cli-windows-x64.exe
```
