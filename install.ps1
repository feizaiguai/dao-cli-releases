# DAO-CLI Windows installer (PowerShell)
# Install command: irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex

param(
    [string]$Version = "1.8.22",
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\dao-cli"
)

$ErrorActionPreference = "Stop"

$Arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
$Platform = "windows"
$AssetBase = "https://github.com/feizaiguai/dao-cli-releases/releases/download/v$Version"
$BackupAssetBase = "https://mirror.ghproxy.com/https://github.com/feizaiguai/dao-cli-releases/releases/download/v$Version"

Write-Host "DAO-CLI v$Version installer" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Install directory: $InstallDir"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$daoUrl     = "$AssetBase/dao-$Platform-$Arch.exe"
$daoCLiUrl  = "$AssetBase/dao-cli-$Platform-$Arch.exe"
$daoPath    = Join-Path $InstallDir "dao.exe"
$daoCliPath = Join-Path $InstallDir "dao-cli.exe"

Write-Host "Downloading dao.exe ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $daoUrl -OutFile $daoPath -UseBasicParsing
    Write-Host "  [OK] dao.exe (primary source)" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Primary source failed; trying backup mirror..." -ForegroundColor Yellow
    try {
        $backupDaoUrl = "$BackupAssetBase/dao-$Platform-$Arch.exe"
        Invoke-WebRequest -Uri $backupDaoUrl -OutFile $daoPath -UseBasicParsing
        Write-Host "  [OK] dao.exe (backup mirror)" -ForegroundColor Green
    } catch {
        Write-Host "  [WARN] Backup mirror failed; trying Gitee mirror..." -ForegroundColor Yellow
        try {
            $giteeDaoUrl = "https://gitee.com/feizaiguai/dao-cli-releases/raw/main/staging-v$Version/dao-$Platform-$Arch.exe"
            Invoke-WebRequest -Uri $giteeDaoUrl -OutFile $daoPath -UseBasicParsing
            Write-Host "  [OK] dao.exe (Gitee mirror)" -ForegroundColor Green
        } catch {
            Write-Host "  [ERROR] Failed to download dao.exe: $_" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "Downloading dao-cli.exe ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $daoCLiUrl -OutFile $daoCliPath -UseBasicParsing
    Write-Host "  [OK] dao-cli.exe (primary source)" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Primary source failed; trying backup mirror..." -ForegroundColor Yellow
    try {
        $backupDaoCliUrl = "$BackupAssetBase/dao-cli-$Platform-$Arch.exe"
        Invoke-WebRequest -Uri $backupDaoCliUrl -OutFile $daoCliPath -UseBasicParsing
        Write-Host "  [OK] dao-cli.exe (backup mirror)" -ForegroundColor Green
    } catch {
        Write-Host "  [WARN] Backup mirror failed; trying Gitee mirror..." -ForegroundColor Yellow
        try {
            $giteeDaoCliUrl = "https://gitee.com/feizaiguai/dao-cli-releases/raw/main/staging-v$Version/dao-cli-$Platform-$Arch.exe"
            Invoke-WebRequest -Uri $giteeDaoCliUrl -OutFile $daoCliPath -UseBasicParsing
            Write-Host "  [OK] dao-cli.exe (Gitee mirror)" -ForegroundColor Green
        } catch {
            Write-Host "  [ERROR] Failed to download dao-cli.exe: $_" -ForegroundColor Red
            exit 1
        }
    }
}

$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", "User")
    Write-Host "Added $InstallDir to user PATH" -ForegroundColor Green
} else {
    Write-Host "Install directory already exists in PATH; skipped" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Install complete. Restart the terminal, then run:" -ForegroundColor Green
Write-Host ""
Write-Host "  dao --version" -ForegroundColor White
Write-Host "  dao doctor" -ForegroundColor White
Write-Host "  dao login --provider deepseek" -ForegroundColor White
Write-Host "  dao" -ForegroundColor White
Write-Host ""
Write-Host "Release page: https://github.com/feizaiguai/dao-cli-releases/releases/latest" -ForegroundColor Gray
