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
    emacs-pgtk
    wl-clipboard
    adwaita-icon-theme
    gnome-themes-extra
  ];

  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark"; # or "default" for light
          gtk-theme = "Adwaita";
        };
      };
    }
  ];

  programs.zsh.enable = true;
  users.users."xtovarisch".shell = pkgs.zsh;
  services.dbus.enable = true;
  fonts.fontconfig.enable = true;

  programs.ssh.startAgent = true;
  environment.variables = {
    GTK_THEME = "Adwaita:dark";
    GDK_BACKEND = "wayland";
    G_MESSAGES_DEBUG = "all";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
