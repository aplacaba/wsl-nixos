# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  wsl.enable = true;
  wsl.defaultUser = "xtovarisch";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  fonts.packages = with pkgs; [
    dejavu_fonts
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
    mise
    starship
    gnumake
    cmake
    libtool
    gcc
    openssl
    libffi
    libjpeg8
    nodejs
    gnupg
    xauth
  ];

  # WSLg (Wayland/X11) is disabled, so no GUI packages or settings needed

  programs.zsh.enable = true;
  users.users."xtovarisch".shell = pkgs.zsh;
  fonts.fontconfig.enable = true;

  programs.ssh.startAgent = true;

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
