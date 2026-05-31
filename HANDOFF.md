# Handoff — wsl-nixos

## Overview

NixOS-WSL flake-based configuration for a WSL environment. Emacs is the
primary GUI application, launched from a Windows shortcut.

## Files

| File | Purpose |
|------|---------|
| `configuration.nix` | Main NixOS config — packages, services, system settings |
| `flake.nix` | Flake entrypoint pointing at `nixpkgs/nixos-unstable` + `NixOS-WSL/main` |
| `flake.lock` | Pinned nixpkgs and NixOS-WSL revisions |
| `.gitignore` | Ignores `result` (nix build symlink) |

## Key Decisions

### Why `emacs` + `gsettings-desktop-schemas` instead of `emacs-pgtk`?

WSLg provides an **X11** display (not Wayland). There are three Emacs
variants in nixpkgs:

| Variant | GUI backend | Schemas in closure |
|---------|-------------|-------------------|
| `emacs` | X11 (Xt/Xaw) | ❌ — needs `gsettings-desktop-schemas` added manually |
| `emacs-pgtk` | Wayland (PGTK) | ✅ — pulls in `gtk3` + `gsettings-desktop-schemas` |
| `emacs-nox` | None | N/A |

`emacs-pgtk` defaults to Wayland and fails to display on WSLg (which only
exposes X11). `emacs` uses X11 directly, so it works with WSLg out of the
box. The tradeoff is that `emacs` doesn't bundle GLib GSettings schemas,
so `gsettings-desktop-schemas` is added explicitly to suppress the
`GLib-GIO-CRITICAL` warning at startup.

### Why `~/.local/bin/emacs-gui` instead of inline shortcut?

The original shortcut used a `bash -lc` one-liner. Moving the launch
logic to a script means:
- Easier to tweak (add flags, change terminal behavior, etc.)
- No need to edit the Windows shortcut
- Can be version-controlled alongside the rest of the config

### WSLg state

WSLg is **running** — `/mnt/wslg/` exists and `DISPLAY` is set to
`10.255.255.254:0.0`. No Wayland compositor is active
(`WAYLAND_DISPLAY` is empty). The WSLg X11 socket mount is handled
automatically by NixOS-WSL.

### `systemd.tmpfiles` for lingering

```nix
systemd.tmpfiles.settings."50-linger" = {
  "/var/lib/systemd/linger/xtovarisch".f = {
    mode = "0644";
    user = "root";
    group = "root";
  };
};
```

Enables the systemd user manager (`user@.service`) at boot. WSL terminals
don't go through PAM login, so no session is created otherwise. Lingering
ensures user services (ssh-agent, etc.) start automatically.

### No `systemd.mounts` clearing

`systemd.mounts` must not be cleared here — it breaks the
`suid-sgid-wrappers` tmpfs mount, which breaks `sudo`.

## Windows Shortcut

Create a shortcut with **Target**:

```
C:\Windows\System32\wsl.exe ~ -e /home/xtovarisch/bin/emacs-gui
```

The script (`emacs-gui`) runs `nohup emacs >/dev/null 2>&1 & disown`,
launching Emacs in the background and immediately exiting the shell,
which closes the terminal window.

## Building

```bash
sudo nixos-rebuild switch
```

## Unresolved / Future

- `emacs-gui` is in `~/bin/` (outside the nix store) — not reproducible
  across rebuilds. Could be replaced with a nix-managed derivation or
  added to `environment.systemPackages` as a wrapper script.
- If WSLg is ever re-enabled with Wayland, `emacs-pgtk` would be the
  better choice again.
