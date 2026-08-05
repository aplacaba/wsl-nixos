# AGENTS.md — wsl-nixos

This file documents the project for AI coding agents (like pi, Claude Code,
Copilot, etc.). It captures architecture, design decisions, conventions, and
common workflows so agents can operate effectively.

---

## Project Overview

**wsl-nixos** is a [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
flake configuration for a development environment running inside WSL2 on
Windows. Emacs (X11 GUI via VcXsrv) is the primary editor. Tmux provides
terminal multiplexing with Emacs-friendly keybindings.

## Repository Structure

```
.
├── AGENTS.md              ← This file — agent guidance
├── HANDOFF.md             ← Human-oriented handoff (detailed decisions)
├── README.md              ← User-facing docs
├── configuration.nix      ← Main NixOS config (packages, services, tmux, etc.)
├── flake.nix              ← Flake entrypoint (nixpkgs + NixOS-WSL)
├── flake.lock             ← Pinned inputs
├── package-lock.json      ← Empty marker (npm init side-effect)
├── .gitignore             ← Ignores `result` (nix build symlink) and HANDOFF.md
├── bin/
│   └── emacs-gui          ← Shell script wrapped in nix derivation to launch Emacs via systemd-run
└── windows/
    ├── emacs.bat          ← Windows batch file (double-click to launch Emacs GUI)
    └── launch-emacs.ps1   ← PowerShell launcher (starts VcXsrv if needed, sets DISPLAY)
```

## Key Files & Their Roles

### `configuration.nix`
The single NixOS module. Covers:
- **System packages** — git, emacs, tmux, zsh, kubectl, terraform, azure-cli, awscli2, dev tools, etc.
- **Tmux** — configured via `programs.tmux` with Emacs-friendly bindings (C-b prefix, M-arrow pane nav, emacs copy mode)
- **Zsh** — enabled as default shell for user `xtovarisch`
- **SSH agent** — started via `programs.ssh.startAgent`
- **Emacs GUI launcher** — wrapped as a bin via `writeShellScriptBin`
- **GSettings schema path** — set to suppress Emacs GLib-GIO warnings
- **Systemd lingering** — tmpfiles entry to ensure user services start at boot
- **Nix-ld** — enabled for running pre-built dynamic binaries without patchelf
- **Fonts** — nerd-fonts.dejavu-sans-mono

### `flake.nix`
Standard flake with two inputs: `nixpkgs/nixos-unstable` and `NixOS-WSL/main`.
Outputs a single `nixosConfiguration` named `nixos` targeting `x86_64-linux`.

### `bin/emacs-gui`
Shell script (wrapped in nix) that:
1. Discovers the Windows host IP via `ip route`
2. Launches Emacs via `systemd-run --user` with the correct `DISPLAY`

### `windows/emacs.bat` / `windows/launch-emacs.ps1` / `windows/alacritty.toml`
Windows-side files. `launch-emacs.ps1` starts VcXsrv if not running,
auto-detects the WSL2 gateway IP, and launches Emacs via `setsid` so it
survives the WSL terminal. `alacritty.toml` is deployed to
`%APPDATA%\alacritty\alacritty.toml` and launches a WSL shell via `wsl ~`.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Distro | NixOS (via NixOS-WSL) |
| Package manager | Nix (flakes) |
| Shell | Zsh + starship prompt |
| Editor | Emacs (X11 GTK via VcXsrv) |
| Terminal multiplexer | Tmux (C-b prefix, emacs mode-keys) |
| Terminal emulator | Windows Terminal or any Win32 terminal |
| X server | VcXsrv on Windows host |
| Dev tools | git, ripgrep, btop, mise, kubectl, terraform, azure-cli, awscli2 |
| Languages | sbcl (Common Lisp), nodejs, gcc toolchain |

## Design Decisions

### Emacs variant: `emacs` (not `emacs-pgtk` or `emacs-nox`)
- WSLg exposes only **X11**, not Wayland → `emacs-pgtk` (Wayland-native) fails
- `emacs` uses X11 directly → works out of the box
- Tradeoff: doesn't bundle GSettings schemas → `gsettings-desktop-schemas` added manually

### Tmux prefix: `C-b` (default)
- Chosen over `C-\` (previous choice) for familiarity
- Pane navigation via `M-arrows` to keep `C-arrows` free for Emacs
- Copy mode uses Emacs keybindings (`C-p`, `C-n`, `C-f`, `C-b`, `C-a`, `C-e`, `C-space`, `C-w`)

### WSLg state
- `guiApplications=false` in `.wslconfig` → VcXsrv handles display
- WSLg X11 socket mount still present but unused (harmless)

### Systemd lingering via tmpfiles
- WSL terminals don't go through PAM login → no systemd user session
- `systemd.tmpfiles.settings."50-linger"` creates `/var/lib/systemd/linger/xtovarisch`
- Ensures `user@.service`, ssh-agent, and user services start at boot

## Building & Deploying

```bash
# Switch to the new config (must be run in the repo root)
sudo nixos-rebuild switch

# Test build without switching
sudo nixos-rebuild build

# Update flake inputs
nix flake update
```

## Common Workflows

### Adding a package
Edit `configuration.nix` → `environment.systemPackages` → rebuild.

### Modifying tmux config
Edit the `extraConfig` block under `programs.tmux` → rebuild → `tmux kill-server` → restart.

### Launching Emacs GUI
- From Windows: double-click `emacs.bat`
- From WSL: `emacs-gui` (wraps `systemd-run --user --no-block emacs`)

### Updating Windows launcher
Edit `windows/emacs.bat` or `windows/launch-emacs.ps1` — these aren't managed by Nix, so no rebuild needed.

## Agent Conventions

- **Always read the full file** before editing `configuration.nix` — tmux config is embedded as a multi-line string
- **Nix string escaping**: `''` strings treat `\` literally (no escape sequences). The only escape is `''` → `'`.
- **Tmux config escaping**: Inside the extraConfig, `C-\\` is the correct way to write a literal `C-\` key (double backslash in tmux config represents a literal backslash)
- **Rebuild** after changing `configuration.nix` or `flake.nix`
- **Windows scripts** are not managed by Nix — edit them directly

## Related Docs

- [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
- [NixOS tmux module](https://search.nixos.org/options?channel=unstable&query=programs.tmux)
- [VcXsrv](https://vcxsrv.com/)
