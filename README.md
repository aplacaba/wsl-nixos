# wsl-nixos

NixOS-WSL configuration for my development environment.

## Building

```bash
sudo nixos-rebuild switch
```

## Running Emacs from a Windows shortcut

Emacs is launched via a PowerShell script that starts VcXsrv if needed,
then runs Emacs in WSL with the correct `DISPLAY`:

```
emacs.bat → launch-emacs.ps1 → wsl → emacs
```

### Windows side

Copy **`windows/emacs.bat`** and **`windows/launch-emacs.ps1`** from
this repo to your Windows user folder (e.g. `C:\Users\A\`).  Then
double-click `emacs.bat` to launch Emacs:

**`emacs.bat`**
```bat
@echo off

@rem launch emacs
powershell -NoProfile -ExecutionPolicy Bypass -Command "& './launch-emacs.ps1'"
```

**`launch-emacs.ps1`** — starts VcXsrv if not already running, auto-detects
the WSL2 gateway IP, sets `DISPLAY`, and launches Emacs via `setsid` so it
survives the terminal:
```powershell
# WSL2 - Launch Emacs

if (-not (Get-Process vcxsrv -ErrorAction SilentlyContinue)) {
    Write-Host "VcXsrv is not running. Starting XLaunch..." -ForegroundColor Yellow
    Start-Process "C:\Program Files\VcXsrv\xlaunch.exe" -ArgumentList ":0 -multiwindow -clipboard -wgl -ac"
} else {
    Write-Host "VcXsrv is already running." -ForegroundColor Green
}

# Get the IP to use from wsl and set to a variable.
$wslip = wsl -d NixOs zsh -c 'ip route | awk ''/default via /'' | cut -d'' '' -f3'

# Run Emacs
wsl -d NixOs zsh -c "export DISPLAY=$wslip`:0.0 export LIBGL_ALWAYS_INDIRECT=1 && setsid emacs"
```

> **Note:** The script launches Emacs inside the default WSL shell with
> `setsid` to detach it from the WSL client process, ensuring the GUI
> window stays open after the console exits.

## Included Tooling

| Tool | Package |
|------|---------|
| Terraform | `terraform` |
| Azure CLI | `azure-cli` |
| AWS CLI | `awscli2` |
| Emacs (GUI) | `emacs` |
| Emacs launcher | `windows/emacs.bat` / `windows/launch-emacs.ps1` |

## Prerequisites

- [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) installed
- A Windows X server (e.g. [VcXsrv](https://vcxsrv.com/)) running on the
  Windows host — the script auto-detects the Windows host IP from the
  WSL2 gateway and sets `DISPLAY` accordingly.
- Windows `.wslconfig` (`%USERPROFILE%\.wslconfig`) should have
  `guiApplications=false` when using a third-party X server (unless you
  use WSLg).
- The default WSL distribution must be named `NixOs` (or adjust the
  `-d NixOs` flag in `launch-emacs.ps1`).
