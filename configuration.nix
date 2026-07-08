# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  wsl.enable = true;

  # Nix-ld: provides /lib/ld-linux-x86-64.so.2 and other standard library
  # paths so dynamically linked executables (e.g. opencode, many pre-built
  # binaries) can run on NixOS without manual patchelf.
  programs.nix-ld.enable = true;
  wsl.defaultUser = "xtovarisch";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  fonts.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    btop
    ripgrep
    zsh
    libvterm
    sbcl
    emacs
    gsettings-desktop-schemas
    kubectl
    kubectx
    mise
    starship
    stow
    tmux
    gnumake
    cmake
    libtool
    gcc
    glibc
    openssl
    p7zip
    libffi
    libjpeg8
    nodejs
    gnupg
    xauth
    terraform
    azure-cli
    awscli2
    (pkgs.writeShellScriptBin "emacs-gui" (builtins.readFile ./bin/emacs-gui))
  ];

  # Point GLib/GIO to GSettings schemas so emacs doesn't print
  # "GLib-GIO-CRITICAL: g_settings_schema_source_lookup" at startup.
  environment.variables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
  };

  # WSLg is disabled (guiApplications=false in .wslconfig).
  # GUI apps use VcXsrv on the Windows host instead.
  # DISPLAY is set dynamically by the emacs-gui script.

  programs.zsh.enable = true;
  users.users."xtovarisch".shell = pkgs.zsh;
  fonts.fontconfig.enable = true;

  programs.ssh.startAgent = true;

  programs.tmux = {
    enable = true;
    clock24 = true;
    historyLimit = 50000;
    extraConfig = ''
      # ── Prefix ──────────────────────────────────────────────────
      # C-b — default tmux prefix.
      set -g prefix C-b
      bind C-b send-prefix

      # ── Key bindings (Emacs-friendly) ───────────────────────────
      # Split panes like Emacs window splits
      bind | split-window -h    # vertical  (like C-x 3)
      bind - split-window -v    # horizontal (like C-x 2)

      # Navigate panes with C-M-arrows (keeps C-arrows free for Emacs)
      bind -n M-Left  select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up    select-pane -U
      bind -n M-Down  select-pane -D

      # Quick resizing with M-S-arrows
      bind -n M-S-Left  resize-pane -L 5
      bind -n M-S-Right resize-pane -R 5
      bind -n M-S-Up    resize-pane -U 5
      bind -n M-S-Down  resize-pane -D 5

      # New window / kill pane on familiar keys
      bind C-c new-window -c "#{pane_current_path}"
      bind C-k kill-pane

      # ── Copy mode (Emacs keybindings) ───────────────────────────
      set-window-option -g mode-keys emacs
      bind -T copy-mode-vi C-p send-keys -X cursor-up
      bind -T copy-mode-vi C-n send-keys -X cursor-down
      bind -T copy-mode-vi C-f send-keys -X cursor-right
      bind -T copy-mode-vi C-b send-keys -X cursor-left
      bind -T copy-mode-vi M-f send-keys -X cursor-word-right
      bind -T copy-mode-vi M-b send-keys -X cursor-word-left
      bind -T copy-mode-vi C-a send-keys -X start-of-line
      bind -T copy-mode-vi C-e send-keys -X end-of-line
      bind -T copy-mode-vi M-< send-keys -X history-top
      bind -T copy-mode-vi M-> send-keys -X history-bottom
      bind -T copy-mode-vi C-v send-keys -X page-down
      bind -T copy-mode-vi M-v send-keys -X page-up
      bind -T copy-mode-vi C-space send-keys -X begin-selection
      bind -T copy-mode-vi C-w send-keys -X copy-selection-and-cancel

      # ── Mouse ───────────────────────────────────────────────────
      set -g mouse on

      # ── UI ──────────────────────────────────────────────────────
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"   # true colour
      set -g base-index 1          # number windows from 1
      set -g renumber-windows on   # auto-renumber on close
      set -g set-clipboard on      # sync with system clipboard

      # Status bar — clean and minimal
      set -g status-interval 5
      set -g status-left-length 40
      set -g status-right-length 60
      set -g status-style "fg=#a0a0c0,bg=#1a1a2e"
      set -g message-style "fg=#e0e0ff,bg=#2d2d44"

      set -g status-left " #[fg=#7ec8e3,bold]#S "
      set -g status-right " #[fg=#a0a0c0]%H:%M #[fg=#7ec8e3]%d-%b-%y "

      # Window format
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #[fg=#1a1a2e,bg=#7ec8e3,bold]#I:#W "
      set -g window-status-separator ""

      # Make pane borders visible
      set -g pane-border-style "fg=#3a3a5c"
      set -g pane-active-border-style "fg=#7ec8e3"

      # ── Start sessions in the current dir ───────────────────────
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
      bind '%' split-window -h -c "#{pane_current_path}"
    '';
  };

  # WSLg X11 socket mount is automatically handled by NixOS-WSL;
  # if WSLg is disabled the mount will simply fail at boot (harmless).
  # DO NOT clear systemd.mounts here — it breaks sudo (suid-sgid-wrappers tmpfs mount).

  # Enable systemd user manager (user@.service) for the user
  # WSL terminals don't go through PAM login, so no session is created.
  # Lingering ensures the user manager starts at boot.
  systemd.tmpfiles.settings."50-linger" = {
    "/var/lib/systemd/linger/xtovarisch".f = {
      mode = "0644";
      user = "root";
      group = "root";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
