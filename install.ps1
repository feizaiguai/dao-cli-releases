# DAO-CLI 涓€閿畨瑁呰剼鏈?(Windows PowerShell)
# 鐢ㄦ硶: irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex

param(
    [string]$Version = "1.1.2",
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\dao-cli"
)

$ErrorActionPreference = "Stop"

$Arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
$Platform = "windows"
$AssetBase = "https://github.com/feizaiguai/dao-cli-releases/releases/download/v$Version"

Write-Host "DAO-CLI v$Version 瀹夎绋嬪簭" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "瀹夎鐩綍: $InstallDir"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$daoUrl     = "$AssetBase/dao-$Platform-$Arch.exe"
$daoCLiUrl  = "$AssetBase/dao-cli-$Platform-$Arch.exe"
$daoPath    = Join-Path $InstallDir "dao.exe"
$daoCliPath = Join-Path $InstallDir "dao-cli.exe"

Write-Host "姝ｅ湪涓嬭浇 dao.exe ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $daoUrl -OutFile $daoPath -UseBasicParsing
    Write-Host "  [OK] dao.exe" -ForegroundColor Green
} catch {
    Write-Host "  [閿欒] 涓嬭浇澶辫触: $_" -ForegroundColor Red
    Write-Host "  璇风‘璁?v$Version 宸插彂甯冨埌: $AssetBase" -ForegroundColor Yellow
    exit 1
}

Write-Host "姝ｅ湪涓嬭浇 dao-cli.exe ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $daoCLiUrl -OutFile $daoCliPath -UseBasicParsing
    Write-Host "  [OK] dao-cli.exe" -ForegroundColor Green
} catch {
    Write-Host "  [閿欒] 涓嬭浇澶辫触: $_" -ForegroundColor Red
    exit 1
}

$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", "User")
    Write-Host "宸插皢 $InstallDir 娣诲姞鍒扮敤鎴?PATH" -ForegroundColor Green
} else {
    Write-Host "PATH 宸插寘鍚畨瑁呯洰褰曪紝璺宠繃" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "瀹夎瀹屾垚锛佽閲嶆柊鎵撳紑缁堢锛岀劧鍚庤繍琛岋細" -ForegroundColor Green
Write-Host ""
Write-Host "  dao --version" -ForegroundColor White
Write-Host "  dao doctor" -ForegroundColor White
Write-Host "  dao login --provider deepseek" -ForegroundColor White
Write-Host "  dao" -ForegroundColor White
Write-Host ""
Write-Host "閰嶇疆鏂囨。: https://github.com/feizaiguai/dao-cli" -ForegroundColor Gray
