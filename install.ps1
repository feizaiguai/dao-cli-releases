# DAO-CLI Windows 安装脚本（PowerShell）
# 安装命令: irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex

param(
    [string]$Version = "1.7.9",
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\dao-cli"
)

$ErrorActionPreference = "Stop"

$Arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
$Platform = "windows"
$AssetBase = "https://github.com/feizaiguai/dao-cli-releases/releases/download/v$Version"
$BackupAssetBase = "https://mirror.ghproxy.com/https://github.com/feizaiguai/dao-cli-releases/releases/download/v$Version"

Write-Host "DAO-CLI v$Version 安装程序" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "安装目录: $InstallDir"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$daoUrl     = "$AssetBase/dao-$Platform-$Arch.exe"
$daoCLiUrl  = "$AssetBase/dao-cli-$Platform-$Arch.exe"
$daoPath    = Join-Path $InstallDir "dao.exe"
$daoCliPath = Join-Path $InstallDir "dao-cli.exe"

Write-Host "正在下载 dao.exe ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $daoUrl -OutFile $daoPath -UseBasicParsing
    Write-Host "  [OK] dao.exe（主下载源）" -ForegroundColor Green
} catch {
    Write-Host "  [警告] 主下载源不可用，正在尝试备用镜像..." -ForegroundColor Yellow
    try {
        $backupDaoUrl = "$BackupAssetBase/dao-$Platform-$Arch.exe"
        Invoke-WebRequest -Uri $backupDaoUrl -OutFile $daoPath -UseBasicParsing
        Write-Host "  [OK] dao.exe（备用镜像）" -ForegroundColor Green
    } catch {
        Write-Host "  [警告] 备用镜像不可用，正在尝试 Gitee 镜像..." -ForegroundColor Yellow
        try {
            $giteeDaoUrl = "https://gitee.com/feizaiguai/dao-cli-releases/raw/main/staging-v$Version/dao-$Platform-$Arch.exe"
            Invoke-WebRequest -Uri $giteeDaoUrl -OutFile $daoPath -UseBasicParsing
            Write-Host "  [OK] dao.exe（Gitee 镜像）" -ForegroundColor Green
        } catch {
            Write-Host "  [错误] dao.exe 下载失败: $_" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "正在下载 dao-cli.exe ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $daoCLiUrl -OutFile $daoCliPath -UseBasicParsing
    Write-Host "  [OK] dao-cli.exe（主下载源）" -ForegroundColor Green
} catch {
    Write-Host "  [警告] 主下载源不可用，正在尝试备用镜像..." -ForegroundColor Yellow
    try {
        $backupDaoCliUrl = "$BackupAssetBase/dao-cli-$Platform-$Arch.exe"
        Invoke-WebRequest -Uri $backupDaoCliUrl -OutFile $daoCliPath -UseBasicParsing
        Write-Host "  [OK] dao-cli.exe（备用镜像）" -ForegroundColor Green
    } catch {
        Write-Host "  [警告] 备用镜像不可用，正在尝试 Gitee 镜像..." -ForegroundColor Yellow
        try {
            $giteeDaoCliUrl = "https://gitee.com/feizaiguai/dao-cli-releases/raw/main/staging-v$Version/dao-cli-$Platform-$Arch.exe"
            Invoke-WebRequest -Uri $giteeDaoCliUrl -OutFile $daoCliPath -UseBasicParsing
            Write-Host "  [OK] dao-cli.exe（Gitee 镜像）" -ForegroundColor Green
        } catch {
            Write-Host "  [错误] dao-cli.exe 下载失败: $_" -ForegroundColor Red
            exit 1
        }
    }
}

$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", "User")
    Write-Host "已将 $InstallDir 添加到用户 PATH" -ForegroundColor Green
} else {
    Write-Host "安装目录已在 PATH 中，跳过添加" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "安装完成。请重启终端，然后运行:" -ForegroundColor Green
Write-Host ""
Write-Host "  dao --version" -ForegroundColor White
Write-Host "  dao doctor" -ForegroundColor White
Write-Host "  dao login --provider deepseek" -ForegroundColor White
Write-Host "  dao" -ForegroundColor White
Write-Host ""
Write-Host "发布页: https://github.com/feizaiguai/dao-cli-releases/releases/latest" -ForegroundColor Gray
