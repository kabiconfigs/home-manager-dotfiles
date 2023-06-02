{ config, pkgs, lib, ... }:

let 
  dbus-hyprland-environment = pkgs.writeTextFile {
    name = "dbus-hyprland-environment";
    destination = "/bin/dbus-hyprland-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

    configure-gtk = pkgs.writeTextFile {
      name = "configure-gtk";
      destination = "/bin/configure-gtk";
      executable = true;
      text = let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gesettings/schemas/${schema.name}";
      in ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gesettings set $gnome_schema gtk-theme 'Catppuccin-Frappe-Compact-Pink-Dark'
        '';
    };

    flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
    hyprland = (import flake-compat {
      src = builtins.fetchTarball "https://github.com/vaxerski/Hyprland/archive/master.tar.gz";
    }).defaultNix;

    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  environment.systemPackages = with pkgs; [
    catppuccin-gtk
    hyprpaper
    hyprland-protocols
    dbus-hyprland-environment
    slurp
    wayland
    glib
    grim
    wl-clipboard
    wlr-randr
    swaybg
    wofi
    foot
    ffmpeg
    krita
    imagemagick
    bc
    aseprite
    transmission-gtk
    bandwhich
    grex
    fd
    xh
    jq
    lm_sensors
    ledger_agent
    catimg
    cached-nix-shell
    todo
    yt-dlp
    tdesktop
    hyperfine
    glow
    nmap
    unzip
    rsync
    gamemode
    hyprpicker
  ];

  services.gvfs.enable = true;
  services.tumbler.enable = true;

  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin
    thunar-dropbox-plugin 
  ];

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = [
     pkgs.xdg-desktop-portal-gtk
     pkgs.xdg-desktop-portal-hyprland
   ];
 };

  imports = [
    (import "${home-manager}/nixos")
    ./fonts.nix
  ];

  programs.hyprland.enable = true; 
  programs.xwayland.enable = true;

  environment.sessionVariables = rec {
    XKB_DEFAULT_LAYOUT = "us";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    XDG_BIN_HOME = "$HOME/.local/bin";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_LIB_HOME = "$HOME/.local/lib";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    NIX_AUTO_RUN = "1";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_ENABLE_XINPUT2 = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    GDK_BACKEND = "wayland";
  };

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
      command = "Hyprland";
        user = "kabi";
      };
      default_session = initial_session;
    };
  };

  environment.etc."greetd/environments".text = ''
    Hyprland
  '';

  home-manager.users.kabi = {
    xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;
    xdg.configFile."hypr/hyprpaper.conf".source = ./hyprpaper.conf;
    xdg.configFile."hypr/march7.jpg".source = ./march7.jpg;
  };
} 

