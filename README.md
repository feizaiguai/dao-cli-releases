# DAO-CLI Releases

This public repository only hosts the Windows installer script and prebuilt
release binaries for DAO-CLI.

## Install

Run in Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/feizaiguai/dao-cli-releases/main/install.ps1 | iex
```

## Files

- `install.ps1`: installer and updater script.
- `LATEST_VERSION.txt`: latest published version.
- `staging-v*/`: published binary artifacts and SHA256 checksums.

The application source code is kept in a private repository and is not
published here.
