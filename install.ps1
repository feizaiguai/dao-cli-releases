$ErrorActionPreference = "Stop"

$rawBase = "https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main"
$defaultInstallDir = Join-Path $env:LOCALAPPDATA "DAO-CLI\bin"
$installDir = if ($env:DAO_CLI_INSTALL_DIR) { $env:DAO_CLI_INSTALL_DIR } else { $defaultInstallDir }
$installDir = [System.IO.Path]::GetFullPath($installDir)
$skipPathUpdate = $env:DAO_CLI_SKIP_PATH_UPDATE -match "^(1|true|yes)$"

function Invoke-DaoWebRequest {
    param(
        [Parameter(Mandatory = $true)][string]$Uri,
        [string]$OutFile
    )

    $params = @{ Uri = $Uri; ErrorAction = "Stop" }
    if ($OutFile) {
        $params.OutFile = $OutFile
    }
    if ((Get-Command Invoke-WebRequest).Parameters.ContainsKey("UseBasicParsing")) {
        $params.UseBasicParsing = $true
    }
    Invoke-WebRequest @params
}

function Add-DaoPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $current = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = @()
    if ($current) {
        $parts = $current -split ";" | Where-Object { $_ -and $_.Trim() }
    }

    $alreadyPresent = $parts | Where-Object {
        [string]::Equals(
            [System.IO.Path]::GetFullPath($_),
            [System.IO.Path]::GetFullPath($Path),
            [System.StringComparison]::OrdinalIgnoreCase
        )
    }

    if (-not $alreadyPresent) {
        $newPath = if ($current) { "$current;$Path" } else { $Path }
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    }

    if (($env:Path -split ";") -notcontains $Path) {
        $env:Path = "$Path;$env:Path"
    }
}

function Read-DaoChecksums {
    param([Parameter(Mandatory = $true)][string]$Path)

    $checksums = @{}
    Get-Content -LiteralPath $Path | ForEach-Object {
        if ($_ -match "^\s*([a-fA-F0-9]{64})\s+\*?(.+?)\s*$") {
            $checksums[$Matches[2].Trim()] = $Matches[1].ToLowerInvariant()
        }
    }
    return $checksums
}

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dao-cli-install-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

try {
    $versionResponse = Invoke-DaoWebRequest -Uri "$rawBase/LATEST_VERSION.txt"
    $version = $versionResponse.Content.Trim()
    if (-not $version) {
        throw "LATEST_VERSION.txt is empty."
    }

    $checksumFile = Join-Path $tempDir "dao-cli-artifacts-sha256.txt"
    Invoke-DaoWebRequest -Uri "$rawBase/dao-cli-artifacts-sha256.txt" -OutFile $checksumFile
    $checksums = Read-DaoChecksums -Path $checksumFile

    $assets = @(
        @{ Remote = "dao-windows-x64.exe"; Local = "dao.exe" },
        @{ Remote = "dao-cli-windows-x64.exe"; Local = "dao-cli.exe" }
    )

    foreach ($asset in $assets) {
        $downloadPath = Join-Path $tempDir $asset.Remote
        $installPath = Join-Path $installDir $asset.Local
        Invoke-DaoWebRequest -Uri "$rawBase/$($asset.Remote)" -OutFile $downloadPath

        if (-not $checksums.ContainsKey($asset.Remote)) {
            throw "Missing checksum for $($asset.Remote)."
        }

        $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $downloadPath).Hash.ToLowerInvariant()
        if ($actualHash -ne $checksums[$asset.Remote]) {
            throw "Checksum mismatch for $($asset.Remote). Expected $($checksums[$asset.Remote]), got $actualHash."
        }

        Copy-Item -LiteralPath $downloadPath -Destination $installPath -Force
    }

    Copy-Item -LiteralPath $checksumFile -Destination (Join-Path $installDir "dao-cli-artifacts-sha256.txt") -Force
    Set-Content -LiteralPath (Join-Path $installDir "VERSION") -Value $version -Encoding ASCII

    if (-not $skipPathUpdate) {
        Add-DaoPath -Path $installDir
    }

    $daoVersion = & (Join-Path $installDir "dao.exe") --version
    $cliVersion = & (Join-Path $installDir "dao-cli.exe") --version

    Write-Host "DAO-CLI $version installed to $installDir"
    Write-Host $daoVersion
    Write-Host $cliVersion
    if ($skipPathUpdate) {
        Write-Host "PATH update skipped because DAO_CLI_SKIP_PATH_UPDATE is set."
    } else {
        Write-Host "Open a new terminal, then run: dao-cli"
    }
} finally {
    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
