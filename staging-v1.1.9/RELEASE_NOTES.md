# DAO-CLI v1.1.9

在 v1.1.8 基础上的**发布验收补丁**：无新用户可见功能，确保仓库自测门禁与本机开发环境稳定。

## 修复

- **CHANGELOG 双文件同步**：`crates/tui/CHANGELOG.md` 与 workspace 版本对齐，修复 `changelog_entry_exists_for_current_package_version` 门禁失败
- **provider 测试环境隔离**：存在 `DEEPSEEK_API_KEY` / `DAO_API_KEY` 时，`resolve_effective_provider` 相关测试不再误失败

## 工程

- 全量测试稳定：**3113 passed / 0 failed / 3 ignored**

## 安装

```powershell
irm https://github.com/feizaiguai/dao-cli-releases/releases/latest/download/install.ps1 | iex
```

## 升级

```powershell
dao update
dao --version   # 应显示 1.1.9
```
