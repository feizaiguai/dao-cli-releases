# DAO-CLI Windows installer (PowerShell)
# Usage: irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex

param(
    [string]$Version = "1.6.15",
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\dao-cli"
)

$ErrorActionPreference = "Stop"

$Arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
$Platform = "windows"
$AssetBase = "https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/staging-v$Version"
$BackupAssetBase = "https://raw.gitmirror.com/feizaiguai/dao-cli-releases/main/staging-v$Version"

Write-Host "DAO-CLI v$Version installer" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Install dir: $InstallDir"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$daoUrl     = "$AssetBase/dao-$Platform-$Arch.exe"
$daoCLiUrl  = "$AssetBase/dao-cli-$Platform-$Arch.exe"
$daoPath    = Join-Path $InstallDir "dao.exe"
$daoCliPath = Join-Path $InstallDir "dao-cli.exe"

Write-Host "Downloading dao.exe ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $daoUrl -OutFile $daoPath -UseBasicParsing
    Write-Host "  [OK] dao.exe (via primary source)" -ForegroundColor Green
} catch {
    Write-Host "  [WARNING] Primary source blocked, trying high-speed backup mirror..." -ForegroundColor Yellow
    try {
        $backupDaoUrl = "$BackupAssetBase/dao-$Platform-$Arch.exe"
        Invoke-WebRequest -Uri $backupDaoUrl -OutFile $daoPath -UseBasicParsing
        Write-Host "  [OK] dao.exe (via backup mirror)" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Download failed: $_" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Downloading dao-cli.exe ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $daoCLiUrl -OutFile $daoCliPath -UseBasicParsing
    Write-Host "  [OK] dao-cli.exe (via primary source)" -ForegroundColor Green
} catch {
    Write-Host "  [WARNING] Primary source blocked, trying high-speed backup mirror..." -ForegroundColor Yellow
    try {
        $backupDaoCliUrl = "$BackupAssetBase/dao-cli-$Platform-$Arch.exe"
        Invoke-WebRequest -Uri $backupDaoCliUrl -OutFile $daoCliPath -UseBasicParsing
        Write-Host "  [OK] dao-cli.exe (via backup mirror)" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Download failed: $_" -ForegroundColor Red
        exit 1
    }
}

$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", "User")
    Write-Host "Added $InstallDir to user PATH" -ForegroundColor Green
} else {
    Write-Host "Install dir already in PATH, skipped" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Done. Restart your terminal, then run:" -ForegroundColor Green
Write-Host ""
Write-Host "  dao --version" -ForegroundColor White
Write-Host "  dao doctor" -ForegroundColor White
Write-Host "  dao login --provider deepseek" -ForegroundColor White
Write-Host "  dao" -ForegroundColor White
Write-Host ""
Write-Host "Docs: https://github.com/feizaiguai/dao-cli" -ForegroundColor Gray
