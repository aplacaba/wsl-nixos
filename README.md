# wsl-nixos

NixOS-WSL configuration for my development environment — Emacs GUI via
VcXsrv, tmux with Emacs-friendly keybindings, Zsh, and dev tooling.

> **For AI agents** → see [`AGENTS.md`](AGENTS.md) for architecture,
> decisions, and conventions.
>
> **For detailed handoff notes** → see `HANDOFF.md` (local-only, not in repo).

---

## Quick Start

```bash
sudo nixos-rebuild switch
```

---

## What's Included

| Category | What |
|----------|------|
| **Editor** | Emacs (X11 GUI via VcXsrv), launched from Windows shortcut |
| **Terminal** | Zsh + starship prompt, tmux (C-b prefix, emacs keybindings) |
| **Dev tools** | git, ripgrep, gnumake, cmake, gcc, nodejs, btop |
| **Cloud/Infra** | kubectl, terraform, azure-cli, awscli2 |
| **Languages** | sbcl (Common Lisp), nodejs |
| **Other** | ssh-agent, nix-ld (dynamic binary compat), Nerd Fonts |

## Tmux Quick Reference

Tmux is configured with Emacs-friendly bindings:

| Binding | Action |
|---------|--------|
| **`C-b`** | Prefix key |
| **`C-b` `c`** | New window (current dir) |
| **`C-b` `C-c`** | New window (current dir) |
| **`C-b` `%`** | Split vertical |
| **`C-b` `"`** | Split horizontal |
| **`C-b` `\|`** | Split vertical |
| **`C-b` `-`** | Split horizontal |
| **`C-b` `,`** | Rename window |
| **`C-b` `C-k`** | Kill pane |
| **`C-b` `d`** | Detach |
| **`C-b` `s`** | Session picker |
| **`C-b` `[`** | Enter copy mode |
| **`C-b` `]`** | Paste |
| **`C-b` `n`** / **`C-b` `p`** | Next / previous window |
| **`M-arrows`** | Navigate panes |
| **`M-S-arrows`** | Resize panes (5 units) |
| **`C-space`** | Begin selection (copy mode) |
| **`C-w`** | Copy selection and exit (copy mode) |

Copy mode uses Emacs-style motion (`C-p`, `C-n`, `C-f`, `C-b`, `C-a`,
`C-e`, `M-f`, `M-b`, `M-v`, `C-v`).

> **Note:** `C-b C-b` sends a literal `C-b` to the terminal (passthrough).

## Running Emacs from a Windows Shortcut

Emacs is launched via a PowerShell script that starts VcXsrv if needed,
then runs Emacs in WSL with the correct `DISPLAY`:

```
emacs.bat → launch-emacs.ps1 → wsl → emacs
```

### Setup

Copy the files from `windows/` to your Windows user folder
(e.g. `C:\Users\A\`):

- `windows/emacs.bat`
- `windows/launch-emacs.ps1`

Double-click `emacs.bat` to launch Emacs.

> **Prerequisites:**
> - [VcXsrv](https://vcxsrv.com/) installed on Windows
> - `.wslconfig` has `guiApplications=false` (unless using WSLg)
> - Default WSL distro named `NixOs` (or adjust `-d NixOs` in the script)

## Prerequisites

- [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) installed
- A Windows X server (e.g. [VcXsrv](https://vcxsrv.com/)) on the host
- `.wslconfig` (`%USERPROFILE%\.wslconfig`) should have
  `guiApplications=false` when using a third-party X server
- Default WSL distribution must be named `NixOs`
