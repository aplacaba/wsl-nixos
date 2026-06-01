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
- WSLg enabled (provides the X11 display server for GUI apps)
