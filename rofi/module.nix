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
    xdg.configFile."wofi/style.css".source = ./style.css;
  };

  environment.systemPackages = with pkgs; [
    wofi
  ];
}
