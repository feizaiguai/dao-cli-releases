$ErrorActionPreference = "Stop"

$rawBase = "https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main"
$defaultInstallDir = Join-Path $env:LOCALAPPDATA "Programs\dao-cli"
$legacyInstallDir = Join-Path $env:LOCALAPPDATA "DAO-CLI\bin"
$installDir = if ($env:DAO_CLI_INSTALL_DIR) { $env:DAO_CLI_INSTALL_DIR } else { $defaultInstallDir }
$installDir = [System.IO.Path]::GetFullPath($installDir)
$skipPathUpdate = $env:DAO_CLI_SKIP_PATH_UPDATE -match "^(1|true|yes)$"
$skipHostConnect = $env:DAO_CLI_SKIP_HOST_CONNECT -match "^(1|true|yes)$"

function Connect-DaoHosts {
    param([Parameter(Mandatory = $true)][string]$DaoPath)

    if ($skipHostConnect) {
        Write-Host "DAO host registration skipped because DAO_CLI_SKIP_HOST_CONNECT is set."
        return
    }
    try {
        & $DaoPath hosts auto-setup | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'host auto-setup command failed' }
        $status = & $DaoPath hosts status codex
        if ($LASTEXITCODE -ne 0) { throw 'host status command failed' }
    } catch {
        Write-Warning "DAO host auto-setup failed; binaries are installed. Run dao hosts status codex for details."
        return
    }
    if ($status -eq '已注册（待握手验证）') {
        Write-Host 'DAO host registered: codex. Reload that host to use it.'
    } elseif ($status -eq '等待后装 Codex 自动接入') {
        Write-Host 'DAO will connect Codex on the next normal DAO launch after Codex is installed.'
    } elseif ($status -eq '已关闭 Codex 自动接入') {
        Write-Host 'DAO host auto registration remains disabled by user preference.'
    }
}

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

    function Normalize-DaoPathEntry {
        param([string]$Entry)
        if (-not $Entry) { return $null }
        try {
            return [System.IO.Path]::GetFullPath(
                [Environment]::ExpandEnvironmentVariables($Entry.Trim())
            ).TrimEnd('\', '/')
        } catch {
            return $Entry.Trim().TrimEnd('\', '/')
        }
    }

    $target = Normalize-DaoPathEntry $Path
    $legacy = Normalize-DaoPathEntry $legacyInstallDir
    $removeLegacy = -not [string]::Equals(
        $target,
        $legacy,
        [System.StringComparison]::OrdinalIgnoreCase
    )

    foreach ($scope in @("User", "Process")) {
        $current = if ($scope -eq "Process") {
            $env:Path
        } else {
            [Environment]::GetEnvironmentVariable("Path", "User")
        }
        $seen = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::OrdinalIgnoreCase
        )
        $parts = [System.Collections.Generic.List[string]]::new()
        [void]$seen.Add($target)
        [void]$parts.Add($target)

        foreach ($entry in @($current -split ";")) {
            $normalized = Normalize-DaoPathEntry $entry
            if (-not $normalized) { continue }
            if ($removeLegacy -and [string]::Equals(
                $normalized,
                $legacy,
                [System.StringComparison]::OrdinalIgnoreCase
            )) { continue }
            if ($seen.Add($normalized)) {
                [void]$parts.Add($entry.Trim())
            }
        }

        $newPath = $parts -join ";"
        if ($scope -eq "Process") {
            $env:Path = $newPath
        } else {
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        }
    }
}

function Remove-DaoUpdaterBackups {
    param([Parameter(Mandatory = $true)][string]$Path)

    Get-ChildItem -LiteralPath $Path -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "^(dao|dao-cli)\.old-\d+(?:-(?:\d+|fallback))?$" } |
        ForEach-Object {
            Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
        }
}

function Find-DaoPathConflicts {
    param([Parameter(Mandatory = $true)][string]$ExpectedPath)

    $expected = [System.IO.Path]::GetFullPath($ExpectedPath).TrimEnd('\', '/')
    $found = foreach ($directory in @($env:Path -split ";")) {
        if (-not $directory) { continue }
        foreach ($name in @("dao.exe", "dao-cli.exe")) {
            $candidate = Join-Path $directory.Trim() $name
            if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                $resolved = [System.IO.Path]::GetFullPath($candidate)
                if (-not $resolved.StartsWith(
                    "$expected\",
                    [System.StringComparison]::OrdinalIgnoreCase
                )) {
                    $resolved
                }
            }
        }
    }
    return @($found | Sort-Object -Unique)
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

function Restore-DaoInstallTransaction {
    param([Parameter(Mandatory = $true)][string]$InstallDir)

    $journalPath = Join-Path $InstallDir ".dao-install-transaction.json"
    if (-not (Test-Path -LiteralPath $journalPath -PathType Leaf)) { return }
    $journal = Get-Content -LiteralPath $journalPath -Raw | ConvertFrom-Json -ErrorAction Stop
    if ($journal.schema -ne 'dao.install.pair.v1' -or $journal.backup_name -notmatch '^\.dao-install-backup-[a-f0-9]{32}$') {
        throw "Invalid DAO installation recovery journal: $journalPath"
    }
    $backupDir = Join-Path $InstallDir $journal.backup_name
    $names = @('dao.exe', 'dao-cli.exe', 'dao-cli-artifacts-sha256.txt', 'VERSION')
    foreach ($name in $names) {
        $old = $journal.old.$name
        if ($null -eq $old -or $null -eq $old.present) {
            throw "Incomplete DAO installation recovery journal: $name"
        }
        if ($old.present) {
            $backup = Join-Path $backupDir $name
            if (-not (Test-Path -LiteralPath $backup -PathType Leaf)) {
                throw "Missing DAO installation recovery file: $backup"
            }
            $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $backup).Hash
            if ($actual -ne $old.sha256) {
                throw "DAO installation recovery checksum mismatch: $name"
            }
        }
    }
    foreach ($name in $names) {
        $target = Join-Path $InstallDir $name
        if ($journal.old.$name.present) {
            if ((Test-Path -LiteralPath $target -PathType Leaf) -and
                (Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash -eq $journal.old.$name.sha256) {
                continue
            }
            Copy-Item -LiteralPath (Join-Path $backupDir $name) -Destination $target -Force
            if ((Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash -ne $journal.old.$name.sha256) {
                throw "DAO installation recovery verification failed: $name"
            }
        } elseif (Test-Path -LiteralPath $target -PathType Leaf) {
            Remove-Item -LiteralPath $target -Force
        }
    }
    Remove-Item -LiteralPath $journalPath -Force
    Remove-Item -LiteralPath $backupDir -Recurse -Force
}

function Start-DaoInstallTransaction {
    param([Parameter(Mandatory = $true)][string]$InstallDir)

    $backupName = ".dao-install-backup-$([Guid]::NewGuid().ToString('N'))"
    $backupDir = Join-Path $InstallDir $backupName
    New-Item -ItemType Directory -Path $backupDir -ErrorAction Stop | Out-Null
    $old = @{}
    foreach ($name in @('dao.exe', 'dao-cli.exe', 'dao-cli-artifacts-sha256.txt', 'VERSION')) {
        $target = Join-Path $InstallDir $name
        $present = Test-Path -LiteralPath $target -PathType Leaf
        $entry = @{ present = $present; sha256 = $null }
        if ($present) {
            $entry.sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash
            $backup = Join-Path $backupDir $name
            Copy-Item -LiteralPath $target -Destination $backup -ErrorAction Stop
            if ((Get-FileHash -Algorithm SHA256 -LiteralPath $backup).Hash -ne $entry.sha256) {
                throw "DAO installation backup verification failed: $name"
            }
        }
        $old[$name] = $entry
    }
    $journalPath = Join-Path $InstallDir ".dao-install-transaction.json"
    $journalTemp = Join-Path $InstallDir ".dao-install-transaction.tmp"
    @{ schema = 'dao.install.pair.v1'; backup_name = $backupName; old = $old } |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $journalTemp -Encoding UTF8
    Move-Item -LiteralPath $journalTemp -Destination $journalPath -ErrorAction Stop
    return $backupDir
}

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
try {
    $installLock = [IO.File]::Open(
        (Join-Path $installDir '.dao-install.lock'),
        [IO.FileMode]::OpenOrCreate,
        [IO.FileAccess]::ReadWrite,
        [IO.FileShare]::None
    )
} catch {
    throw "Another DAO installation is already using $installDir : $_"
}

try {
    Restore-DaoInstallTransaction -InstallDir $installDir
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dao-cli-install-" + [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

try {
    $versionResponse = Invoke-DaoWebRequest -Uri "$rawBase/LATEST_VERSION.txt"
    $version = $versionResponse.Content.Trim()
    if (-not $version) {
        throw "LATEST_VERSION.txt is empty."
    }
    if ($version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
        throw "LATEST_VERSION.txt must contain a three-part numeric version."
    }
    $releaseBase = "https://github.com/feizaiguai/dao-cli-releases/releases/download/v$version"

    $checksumFile = Join-Path $tempDir "dao-cli-artifacts-sha256.txt"
    Invoke-DaoWebRequest -Uri "$releaseBase/dao-cli-artifacts-sha256.txt" -OutFile $checksumFile
    $checksums = Read-DaoChecksums -Path $checksumFile

    $assets = @(
        @{ Remote = "dao-windows-x64.exe"; Local = "dao.exe" },
        @{ Remote = "dao-cli-windows-x64.exe"; Local = "dao-cli.exe" }
    )

    foreach ($asset in $assets) {
        $downloadPath = Join-Path $tempDir $asset.Remote
        Invoke-DaoWebRequest -Uri "$releaseBase/$($asset.Remote)" -OutFile $downloadPath

        if (-not $checksums.ContainsKey($asset.Remote)) {
            throw "Missing checksum for $($asset.Remote)."
        }

        $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $downloadPath).Hash.ToLowerInvariant()
        if ($actualHash -ne $checksums[$asset.Remote]) {
            throw "Checksum mismatch for $($asset.Remote). Expected $($checksums[$asset.Remote]), got $actualHash."
        }

    }

    $backupDir = Start-DaoInstallTransaction -InstallDir $installDir
    try {
        foreach ($asset in $assets) {
            $downloadPath = Join-Path $tempDir $asset.Remote
            $installPath = Join-Path $installDir $asset.Local
            Copy-Item -LiteralPath $downloadPath -Destination $installPath -Force
            if ((Get-FileHash -Algorithm SHA256 -LiteralPath $installPath).Hash.ToLowerInvariant() -ne $checksums[$asset.Remote]) {
                throw "DAO installation verification failed: $($asset.Local)"
            }
        }
        Copy-Item -LiteralPath $checksumFile -Destination (Join-Path $installDir "dao-cli-artifacts-sha256.txt") -Force
        Set-Content -LiteralPath (Join-Path $installDir "VERSION") -Value $version -Encoding ASCII
        $daoVersion = & (Join-Path $installDir "dao.exe") --version
        $daoExitCode = $LASTEXITCODE
        $cliVersion = & (Join-Path $installDir "dao-cli.exe") --version
        $cliExitCode = $LASTEXITCODE
        if ($daoExitCode -ne 0 -or $cliExitCode -ne 0 -or
            $daoVersion -notmatch ("^dao " + [regex]::Escape($version) + "(?:\s|$)") -or
            $cliVersion -notmatch ("^dao-cli " + [regex]::Escape($version) + "(?:\s|$)")) {
            throw "DAO installation version readback failed: $version"
        }
        Remove-Item -LiteralPath (Join-Path $installDir ".dao-install-transaction.json") -Force
        try {
            Remove-Item -LiteralPath $backupDir -Recurse -Force
        } catch {
            Write-Warning "Installed pair verified, but backup cleanup failed: $backupDir"
        }
    } catch {
        $failure = $_
        try {
            Restore-DaoInstallTransaction -InstallDir $installDir
        } catch {
            throw "DAO installation failed and automatic recovery failed; recovery journal retained at $installDir : $failure ; $_"
        }
        throw $failure
    }

    if (-not $skipPathUpdate) {
        Add-DaoPath -Path $installDir
    }

    # auto-setup creates a preference only when one is absent, and respects
    # existing registrations and explicit revocation on both install and upgrade.
    Connect-DaoHosts -DaoPath (Join-Path $installDir 'dao.exe')

    Remove-DaoUpdaterBackups -Path $installDir

    $conflicts = Find-DaoPathConflicts -ExpectedPath $installDir

    Write-Host "DAO-CLI $version installed to $installDir"
    Write-Host $daoVersion
    Write-Host $cliVersion
    if ($skipPathUpdate) {
        Write-Host "PATH update skipped because DAO_CLI_SKIP_PATH_UPDATE is set."
    } else {
        Write-Host "Open a new terminal, then run: dao-cli"
    }
    if ($conflicts.Count -gt 0) {
        Write-Warning "Other DAO-CLI executables are still present on PATH:"
        $conflicts | ForEach-Object { Write-Warning "  $_" }
        Write-Warning "Remove those old installations to avoid launching the wrong version."
    }
} finally {
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/') + '\'
    if ($tempDir.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -and
        [IO.Path]::GetFileName($tempDir) -match '^dao-cli-install-[a-f0-9]{32}$') {
        Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
} finally {
    $installLock.Dispose()
}
