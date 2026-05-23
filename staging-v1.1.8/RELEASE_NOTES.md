# DAO-CLI v1.1.8

延续 v1.1.7 的修复，本次以**测试体系健康度**和**品牌一致性**为主，整个工作区从 77 个失败测试清零到 0 个失败、3113 通过。

## 用户可见改进

- **`/config status_indicator` 不再拒绝 `whale`**：v1.1.x 的「invalid status indicator 'whale'」错误已修复。`whale`、`dots`、`off`、`1..10` 全部接受。
- **侧栏 sidebar 隐藏目录可补全**：`@`-mention 与 fuzzy 补全现在能进入 `.dao-cli/commands/`，不再被 `.gitignore` 屏蔽。
- **footer 默认显示模式与模型**：底栏恢复 `mode` + `model` 两个芯片，方便一眼看出当前模式与模型。
- **品牌化收尾**：prompt 模板、auth recovery 提示、`/links` 帮助等剩余 DeepSeek-only 措辞统一为 DAO-CLI / DeepSeek 双向兼容；config 路径继续支持向后兼容读取 `~/.deepseek/config.toml`。

## 测试与工程

- **全量测试通过：3113 passed / 0 failed / 3 ignored**（v1.1.7 还有 77 个失败）。
- Windows 上 Python/Linux-路径相关测试通过 `#[cfg(unix)]` 跳过，Linux CI 仍保持完整覆盖。
- `dao update` BOM 防御自 v1.1.7 起就位；本版本 SHA256 清单沿用 BOM-free UTF-8 编码。

## 安装

### 一键安装（PowerShell，推荐）

```powershell
irm https://github.com/feizaiguai/dao-cli-releases/releases/latest/download/install.ps1 | iex
```

### 升级

```powershell
dao update
```

### 验证

```powershell
dao --version  # 应输出 1.1.8
```

## 已知限制

- 在没有 Python 3 的 Windows 机器上，`code_execution` / `rlm_*` 工具会显示 binary_unavailable 提示，这是设计行为（产品代码在 catalog 构建时探测 interpreter）。
- 双宽 CJK 字符在 ratatui buffer 中会以单字符+空格形式渲染（如 `输 入`），这是 TUI 缓冲区表现，最终终端显示正常。
