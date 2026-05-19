# DAO-CLI 一键安装脚本 (Windows PowerShell)
# 用法: irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex

param(
    [string]$Version = "1.0.9",
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\dao-cli"
)

$ErrorActionPreference = "Stop"

$Arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
$Platform = "windows"
$AssetBase = "https://github.com/feizaiguai/dao-cli-releases/releases/download/v$Version"

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
    Write-Host "  [OK] dao.exe" -ForegroundColor Green
} catch {
    Write-Host "  [错误] 下载失败: $_" -ForegroundColor Red
    Write-Host "  请确认 v$Version 已发布到: $AssetBase" -ForegroundColor Yellow
    exit 1
}

Write-Host "正在下载 dao-cli.exe ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $daoCLiUrl -OutFile $daoCliPath -UseBasicParsing
    Write-Host "  [OK] dao-cli.exe" -ForegroundColor Green
} catch {
    Write-Host "  [错误] 下载失败: $_" -ForegroundColor Red
    exit 1
}

$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", "User")
    Write-Host "已将 $InstallDir 添加到用户 PATH" -ForegroundColor Green
} else {
    Write-Host "PATH 已包含安装目录，跳过" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "安装完成！请重新打开终端，然后运行：" -ForegroundColor Green
Write-Host ""
Write-Host "  dao --version" -ForegroundColor White
Write-Host "  dao doctor" -ForegroundColor White
Write-Host "  dao login --provider deepseek" -ForegroundColor White
Write-Host "  dao" -ForegroundColor White
Write-Host ""
Write-Host "配置文档: https://github.com/feizaiguai/dao-cli" -ForegroundColor Gray
