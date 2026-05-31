# wsl-nixos

NixOS-WSL configuration for my development environment.

## Building

```bash
sudo nixos-rebuild switch
```

## Running Emacs from a Windows shortcut

Create a shortcut on Windows with the following **Target**:

```
C:\Windows\System32\wsl.exe ~ -e bash -lc "nohup emacs >/dev/null 2>&1 & disown"
```

This launches Emacs in the background and closes the terminal window immediately.

## Prerequisites

- [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) installed
- WSLg enabled (provides the X11 display server for GUI apps)
