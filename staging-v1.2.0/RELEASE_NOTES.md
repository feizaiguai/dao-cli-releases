# DAO-CLI v1.2.0 正式版

> 正式发布：全方位解决终端卡死问题，实现异步更新诊断探针与完美的安全隔离

## 新增与改进

- **网络探针全面异步化重构**
  - **现象修复**：彻底解决了在上一版本中运行 `dao doctor` 诊断或 API 连通性测试时，在某些断网/网络限制环境下引发的 Tokio 异步运行时 drop 锁死崩溃（`Cannot drop a runtime in a context where blocking is not allowed`）Panic。
  - **改动细节**：将更新探针及 Ollama 连通性检查全面重构为异步 `reqwest::Client` 并配合 `.await` 调用，即使网络超时也能极速优雅地输出报错，不再锁死崩溃。

- **卡死终极治理与管道句柄大扫除**
  - **根源解决**：彻底修复了在 AI 回合提交时可能残留的后台进程导致的 Windows Stdin/Stdout 管道挂起死锁问题。现在所有后台发起的子进程生命周期已受严格监控且在回合结束前 100% 回收完毕，终端操作如丝般顺滑。

## 工程

- 升级源码仓库与分发仓库的所有配置文件与安装引导脚本（`install.ps1`）的默认版本号至正式的 **`1.2.0`**。
- 工作区全量测试：**编译完美零 Warning/Error 通过**，核心 TUI 启动测试与本地诊断全绿通关。

## 安装

PowerShell：

```powershell
irm https://github.com/feizaiguai/dao-cli-releases/releases/download/v1.2.0/install.ps1 | iex
```

或显式指定版本：

```powershell
& ([scriptblock]::Create((irm https://github.com/feizaiguai/dao-cli-releases/releases/download/v1.2.0/install.ps1))) -Version 1.2.0
```

升级老版本：

```powershell
dao update
```

## 校验

```text
c9c075770919168fafb5cacc957e12193c37d6ec8c49aac034e70617600aa537  dao-windows-x64.exe
2d74ed67e9afbdb395100e4acce475df575f77c58185d8aab58ab12243158b33  dao-cli-windows-x64.exe
```
