{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:{

 imports = [ 
     (import "${home-manager}/nixos")
     ./catppuccin-cursors.nix  
     ./catppuccin-folders.nix  
     ./catppuccin-gtk.nix 
    ];

    home-manager.users.kabi = {
      home.stateVersion = "23.05";
    };

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit  pkgs;
    };
  };
}
