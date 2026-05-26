# DAO-CLI — 发行版

**DAO-CLI** 是面向中文开发者的终端原生编程智能体。

---

## 快速安装

### Windows（PowerShell）

```powershell
irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex
```

---

## 支持平台

| 平台 | 架构 | 二进制名称 |
|------|------|-----------|
| Windows | x64 | `dao-windows-x64.exe` + `dao-cli-windows-x64.exe` |

其他平台预编译包尚未发布到本仓库。

---

## 首次使用

```bash
dao --version          # 确认安装
dao doctor             # 环境诊断
dao auth set --provider deepseek   # 配置 API Key
dao                    # 启动 TUI
```

---

## 支持的模型 Provider

| Provider | 环境变量 |
|----------|---------|
| DeepSeek | `DEEPSEEK_API_KEY` |
| 智谱 GLM | `ZHIPU_API_KEY` |
| Kimi | `MOONSHOT_API_KEY` |
| MiniMax | `MINIMAX_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |
| Gemini | `GEMINI_API_KEY` |

---

> 源代码为私有仓库。本仓库仅用于发布预编译二进制和安装脚本。
