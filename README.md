# wsl-nixos

NixOS-WSL configuration for my development environment.

## Building

```bash
sudo nixos-rebuild switch
```

## Running Emacs from a Windows shortcut

The script `~/bin/emacs-gui` launches Emacs in the background and exits
immediately (no lingering terminal):

```bash
#!/usr/bin/env bash
# Get the Windows host IP (works with VcXsrv or any X server on Windows)
WIN_IP=$(ip route show default | awk '{print $3}')
export DISPLAY=$WIN_IP:0
nohup emacs >/dev/null 2>&1 &
disown
```

Create a Windows shortcut with this **Target**:

```
C:\Windows\System32\wsl.exe ~ -e /home/xtovarisch/bin/emacs-gui
```

This way all the logic lives inside WSL and you can tweak it without
touching the Windows shortcut.

## Included Tooling

| Tool | Package |
|------|---------|
| Terraform | `terraform` |
| Azure CLI | `azure-cli` |
| AWS CLI | `awscli2` |
| Emacs (GUI) | `emacs` |

## Prerequisites

- [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) installed
- A Windows X server (e.g. [VcXsrv](https://vcxsrv.com/)) running on the
  Windows host — the script auto-detects the Windows host IP from the
  WSL2 gateway and sets `DISPLAY` accordingly.
- Windows `.wslconfig` (`%USERPROFILE%\.wslconfig`) should have
  `guiApplications=false` when using a third-party X server.
