{ config, pkgs, ... }:
let
  user = import ../user/kabi.nix;
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.kabi = {
    xdg.configFile."waybar/config".source = ./config;
    xdg.configFile."waybar/style.css".source = ./style.css;
    xdg.configFile."waybar/style-background.css".source = ./style-background.css;
    xdg.configFile."waybar/config-background".source = ./config-background;
    xdg.configFile."waybar/machiatto.css".source = ./machiatto.css;
    xdg.configFile."waybar/scripts".source = ./scripts;
  };

  environment.systemPackages = with pkgs; [
    waybar
  ];
}
