# DAO-CLI — 发行版

**DAO-CLI** 是面向中文开发者的终端原生编程智能体。

---

## 快速安装

### Windows（PowerShell）

```powershell
irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex
```

### 通过 npm（全平台）

```bash
npm install -g @bigbao/dao-cli
```

---

## 支持平台

| 平台 | 架构 | 二进制名称 |
|------|------|-----------|
| Windows | x64 | `dao-windows-x64.exe` + `dao-cli-windows-x64.exe` |
| Linux | x64 | `dao-linux-x64` + `dao-cli-linux-x64` |
| Linux | arm64 | `dao-linux-arm64` + `dao-cli-linux-arm64` |
| macOS | x64 | `dao-macos-x64` + `dao-cli-macos-x64` |
| macOS | Apple Silicon | `dao-macos-arm64` + `dao-cli-macos-arm64` |

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
