# wsl-nixos

NixOS-WSL configuration for my development environment.

## Building

```bash
sudo nixos-rebuild switch
```

## Running Emacs from a Windows shortcut

The `emacs-gui` script (from `bin/emacs-gui` in this repo, installed
system-wide via Nix) launches Emacs in the background and exits
immediately (no lingering terminal):

```bash
#!/usr/bin/env bash
# Auto-detect the Windows host IP from the WSL2 gateway
WIN_IP=$(ip route show default | awk '{print $3}')
export DISPLAY=$WIN_IP:0
nohup emacs >/dev/null 2>&1 &
disown
```

Create a Windows shortcut with this **Target**:

```
C:\Windows\System32\wsl.exe ~ -e bash -lc emacs-gui
```

(`bash -lc` is needed so that the PATH picks up the Nix-installed script.)

All the launch logic lives in the repo under `bin/emacs-gui` — tweak it
there, rebuild, and the shortcut keeps working unchanged.

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
