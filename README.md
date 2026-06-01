# wsl-nixos

NixOS-WSL configuration for my development environment.

## Building

```bash
sudo nixos-rebuild switch
```

## Running Emacs from a Windows shortcut

Emacs is launched via a chain that ensures it survives the WSL client
exiting:

```
emacs-gui.bat → emacs-gui.vbs → wsl → emacs-gui → systemd-run → emacs
```

### Windows side

Copy **`windows/emacs-gui.bat`** and **`windows/emacs-gui.vbs`** from
this repo to your Windows user folder (e.g. `C:\Users\A\`).  Then
double-click `emacs-gui.bat` to launch Emacs:

**`emacs-gui.bat`**
```bat
@echo off
wscript.exe "%~dp0emacs-gui.vbs"
```

**`emacs-gui.vbs`** — starts VcXsrv if needed, then runs WSL
without waiting (so emacs survives):
```vb
shell.Run "wsl ~/bin/emacs-gui", 0, False
```

### WSL side

**`~/bin/emacs-gui`** (tracked in `bin/emacs-gui`) — auto-detects the
Windows host IP, sets `DISPLAY`, and launches emacs via `systemd-run`
so it's a systemd service detached from the WSL client:

```bash
#!/usr/bin/env bash
WIN_IP=$(/run/current-system/sw/bin/ip route show default | /run/current-system/sw/bin/awk '{print $3}')
/run/current-system/sw/bin/systemd-run --user --no-block -q \
    -E "DISPLAY=$WIN_IP:0" \
    /run/current-system/sw/bin/emacs
```

## Included Tooling

| Tool | Package |
|------|---------|
| Terraform | `terraform` |
| Azure CLI | `azure-cli` |
| AWS CLI | `awscli2` |
| Emacs (GUI) | `emacs` |
| Emacs launcher | `emacs-gui` (`bin/emacs-gui`) |

## Prerequisites

- [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) installed
- A Windows X server (e.g. [VcXsrv](https://vcxsrv.com/)) running on the
  Windows host — the script auto-detects the Windows host IP from the
  WSL2 gateway and sets `DISPLAY` accordingly.
- Windows `.wslconfig` (`%USERPROFILE%\.wslconfig`) should have
  `guiApplications=false` when using a third-party X server.
- Systemd user manager enabled (lingering is configured in
  `configuration.nix`).
