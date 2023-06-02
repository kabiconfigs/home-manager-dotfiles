# User settings, applications and preferences
{ config, pkgs, ... }:
let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
in
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {

  imports = [
    (import "${home-manager}/nixos")
   ./firefox.nix
   ./gtk.nix
   ./xdg_dirs.nix
   ./foot/default.nix
  ];

  users.users.kabi = {
    isNormalUser = true;
    description = "kabi";
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "audio" 
      "video" 
      "docker" 
      ];
    };

    # Session variables
    environment.sessionVariables = rec {
      EDITOR          = "nano";
      NIXOS_OZONE_WL  = "1";
    };

    home-manager.users.kabi = {
      home.stateVersion = "23.05";
      programs.home-manager.enable = true;

   home.packages = with pkgs; [
     lutris
     cava
     wineWowPackages.stable
     winetricks
     betterdiscordctl
     discord
     libnotify
     mpv
     imv
     zathura
     neovim
   ];
     xdg.configFile."BetterDiscord/data/stable/custom.css".source = ./bdtheme.css;
     xdg.configFile."btop/themes/btop.theme".source = ./btop.theme;

  services.mako = {
    enable = true;
    actions = true;
    anchor = "bottom-center";
    borderColor = "#ca9ee6";
    backgroundColor = "#232634";
    textColor = "#c6d0f5";
    width = 600;
    borderRadius = 5;
    font = "Lexend 10";
    icons = true;
    iconPath = "${pkgs.system}.catppuccin-folders";
    package = pkgs.mako;
    defaultTimeout = 4000;
  };

   nixpkgs.config.packageOverrides = pkgs: {
     nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
       inherit  pkgs;
      };
    };
  };
}
