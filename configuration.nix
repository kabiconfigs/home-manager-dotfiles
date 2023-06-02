{ inputs, config, lib, pkgs, modulesPath, ... }:
with lib; let

  mkService = lib.recursiveUpdate {
    Unit.PartOf = ["graphical-session.target"];
    Unit.After = ["graphical-session.target"];
    Install.WantedBy = ["graphical-session.target"];
  };
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    #!/bin/bash
    hyprctl keyword animation "fadeOut,0,8,slow" && ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -w 0 -b 5e81acd2)" - | swappy -f -; hyprctl keyword animation "fadeOut,1,8,slow"
  '';
in
let
  hosts = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/2c1f72fd4765fcf31cd70134677ecc38ed860589/hosts";
    sha256 = "0v4gzxcvmmcywlrmvlc0222p4js9acg7sfm21902kp8xir70rac2";
  };
in
let
  aagl-gtk-on-nix = import (builtins.fetchTarball "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz");
in
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {

  home-manager = {
   useGlobalPkgs = true;
   useUserPackages = true;
    users.kabi = {
     home.stateVersion = "23.05";
     home.username = "kabi";
     home.homeDirectory = "/home/kabi";
     home.extraOutputsToInstall = ["doc" "devdoc"];
    };
  };

  programs.git.enable = true;

   imports = [
     ./mounts.nix
     ./user/kabi.nix
     ./hypr/module.nix 
     ./waybar/module.nix
     ./rofi/module.nix
     ./neofetch/module.nix
     ./spotify-tui/module.nix
     ./kernel.nix 
      aagl-gtk-on-nix.module
      (import "${home-manager}/nixos")
    # (modulesPath + "/profiles/qemu-guest.nix")
    # (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  programs.anime-game-launcher.enable = true;
  programs.honkers-railway-launcher.enable = true;

  services = {
    dbus = {
      packages = with pkgs; [dconf gcr udisks2];
      enable = true;
    };
    udev.packages = with pkgs; [gnome.gnome-settings-daemon android-udev-rules ledger-udev-rules];
    journald.extraConfig = ''
      SystemMaxUse=50M
      RuntimeMaxUse=10M
    '';
    udisks2.enable = true;
  };

  networking = {
    extraHosts = builtins.readFile hosts;
    networkmanager.enable = true;
    hostName = "nixos-desktop";
    interfaces.enp5s0.ipv4.addresses = [{
       address= "192.168.0.150";
       prefixLength = 24;
    }];
       defaultGateway = "192.168.0.2";
       nameservers = [ "8.8.8.8" ];
     };

    time = { 
     timeZone = "America/New_York";
     hardwareClockInLocalTime = true;
    };
     hardware.ledger.enable = true;

    services.accounts-daemon.enable = true;

    programs.dconf.enable = true;

    services.nfs.server.enable = true;
    services.samba.enable = true;

  environment.etc."greetd/environments".text = ''
    Hyprland
  '';

  environment.loginShellInit = ''
    dbus-update-activation-environment --systemd DISPLAY
    eval $(gnome-keyring-daemon --start --components=ssh)
    eval $(ssh-agent)
  '';

    environment = {
     sessionVariables = {
      NIX_AUTO_RUN = "1";
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_ENABLE_XINPUT2 = "1";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONEREPARENTING = "1";
      WLR_BACKEND = "vulkan";
      WLR_RENDERER = "vulkan";
      WLR_DRM_DEVICES = "/dev/dri/card0";
      XDG_BIN_HOME = "$HOME/.local/bin";  
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";  
      XDG_DATA_HOME = "$HOME/.local/share";  
      XDG_LIB_HOME = "$HOME/.local/lib";
      ZSTD_CLEVEL = "8";
      ZSTD_NBTHREADS = "20";
    };
      variables = {
        EDITOR = "nano";
        BROWSER = "firefox";
      };
    };

    environment.systemPackages = with pkgs; [
     (pkgs.writeScriptBin "sudo" ''exec doas "$@"'')
     pkgs.nmap
     pkgs.unrar
     pkgs.scrcpy
     pkgs.libdrm
     pkgs.unzip
     pkgs.ntfs3g
     pkgs.exfat
     pkgs.exfatprogs
     pkgs.psmisc
     pkgs.coreutils-full
     pkgs.gptfdisk
     pkgs.parted
     pkgs.p7zip
     pkgs.mg
     pkgs.btop
     pkgs.pciutils
     pkgs.dconf
     pkgs.libguestfs
     pkgs.wget
     pkgs.xfce.thunar
   ];

    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
     ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      openssl
      curl
      glib
      util-linux
      glibc
      icu
      libunwind
      libuuid
      zlib
      libsecret
      # graphical
      freetype
      libglvnd
      libnotify
      SDL2
      vulkan-loader
      gdk-pixbuf
      xorg.libX11
    ];
  };

  services.openssh.enable = true;
  system.copySystemConfiguration = true;

  system.stateVersion = "nixos-unstable"; # Did you read the comment?
  systemd.services = {
    seatd = {
      enable = true;
      description = "Seat management daemon";
      script = "${pkgs.seatd}/bin/seatd -g wheel";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
      };
      wantedBy = ["multi-user.target"];
    };
  };

  services = {
   gnome.gnome-keyring.enable = true;
   gnome.glib-networking.enable = true;
  logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "lock";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      HibernateDelaySec=3600
    '';
   };
 };

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_blk"
    "ehci_pci"
    "nvme"
    "uas"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
    "raid6_pq"
    "scsi_common"
    "scsi_mod"
    "libata" 
 ];

  boot.initrd.kernelModules = [ 
  "dm-snapshot" "dm-cache-default" 
  "dm-raid"
 ];

  boot.kernelParams = [ 
  "intel_iommu=on" "iommu=pt"
  "pcie_ports=native" "acpi_call" 
  "cpufreq.default_governor=performance"
  "video=HDMI-A-2:1920x1080@60" 
  "video=HDMI-A-1:1680x1050@59.954" 
 ];

  boot.kernelModules = [ 
  "vfio" "vfio_iommu_type1" 
  "vfio_pci" "vfio_virqfd"
  "lz4" "z3fold" "zstd" 
  "amdgpu" "kvm-intel" 
  "r8169" "dm-mod"
  "iommu=pt" "btrfs"
  "device-mapper"
  "md_mod" "raid0"
  "t10_pi" "gameport"
  "snd_cmipci" "overlay"
   "scsi_mod"
   "scsi_common"
  ];
  
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [ 
  "nvidia" "nouveau" "btrtl" 
  "btintel" "btbcm" "ath3k" "zfs" 
  "btusb" "bluetooth" "nvidia_uvm"
  "nvidia_drm" "nvidia_modeset" 
  "nvidia" "i2c_nvidia_gpu"
 ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.supportedFilesystems = [ "vfat" "btrfs" ];
  boot.loader = {
     generationsDir.copyKernels = true;
    efi = {
     canTouchEfiVariables = false;
     efiSysMountPoint = "/boot/efi";
    };

  grub = {
     enable = true;
     copyKernels = true;
     zfsSupport = false;
     efiSupport = true;
     efiInstallAsRemovable = true; #
     device = "nodev";
   };
 };

   users = {
    users.kabi = {
       shell = pkgs.zsh;
        isNormalUser = true;
        extraGroups = [
         "wheel"
         "users"
         "rtkit"
         "docker"
         "polkituser"
         "networkmanager"
         "sgx"
         "adm"
         "kmem"
         "tty"
         "messagebus"
         "video"
         "input"
         "render"
         "audio"
         "kvm"
         "avahi"
         "qemu"
         "qemu-libvirtd"
         "nix-serve"
         "mpd"
         "libvirtd"
       ];
     };
   };

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    wireplumber.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs = {
   zsh = {
   enable = true;
   autosuggestions.enable = true;
   syntaxHighlighting = {
   enable = true;
    patterns = {"rm -rf *" = "fg=black,bg=red";};
    styles = {"alias" = "fg=magenta";};
    highlighters = ["main" "brackets" "pattern"];       
   };

  ohMyZsh = {
    enable = true;
    theme = "gentoo";
    plugins = [
     "systemd"
     "bgnotify" 
    ];

      customPkgs = with pkgs; [
        zsh nix-zsh-completions
        zsh-history-substring-search
        zsh-nix-shell bat exa fasd 
        sd fd fzf nix-serve
      ];
    };
  };
};

   programs = {
    mtr.enable = true;
    adb.enable = true;
     gnupg.agent = {
       enable = true;
       enableSSHSupport = true;
      };
      
   tmux = {
     enable = true;
     clock24 = true;
    };
  };
            
  security = {
     sudo.enable = false;
     doas = {
       enable = true;
       extraRules = [{
        users = [ "kabi" ];
        keepEnv = true;
        persist = true;
      }];
    };
  }; 

  i18n = let
    defaultLocale = "en_US.UTF-8";
    us = "en_US.UTF-8";
  in {
    inherit defaultLocale;
    extraLocaleSettings = {
      LANG = defaultLocale;
      LC_COLLATE = defaultLocale;
      LC_CTYPE = defaultLocale;
      LC_MESSAGES = defaultLocale;      
      LC_ADDRESS = us;
      LC_IDENTIFICATION = us;
      LC_MEASUREMENT = us;
      LC_MONETARY = us;
      LC_NAME = us;
      LC_NUMERIC = us;
      LC_PAPER = us;
      LC_TELEPHONE = us;
      LC_TIME = us;
    };
  };
  console = let
    variant = "u24n";
  in {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-${variant}.psf.gz";
    keyMap = "us";
  };

  boot.plymouth.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];  

  hardware = {
   cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
   enableAllFirmware = true;
   enableRedistributableFirmware = lib.mkDefault true;
   acpilight.enable = lib.mkDefault true;
  };
  
   security.pam.loginLimits = [
    { domain = "*"; type = "-"; item = "memlock"; value = "unlimited"; }
    { domain = "*"; type = "-"; item = "nofile"; value = "unlimited"; }
    { domain = "*"; type = "-"; item = "nproc"; value = "unlimited"; }
   ];
  
  services.gnome.at-spi2-core.enable = true;
  
  nixpkgs.config = {
   allowUnfree = true;  
   allowBroken = true;
   enableParallelBuilding = true;          
     operation = "nixos-rebuild switch --upgrade";
     channel = "https://nixos.org/channels/nixos-unstable";
     dates = "hourly";
    };
  
    nix = {
     gc = {
     automatic = true;   
     dates = "*-*-1,4,7,10,13,16,19,22,25,28,31 00:00:00";
     options = "--delete-older-than 7d";
    };

   settings = {
    auto-optimise-store = true;
    cores = 20;
    max-jobs = "auto";
    system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-alderlake" ];
    experimental-features = [ "nix-command" "flakes" ];

   substituters = [
    "https://nix-community.cachix.org"
    "https://cache.nixos.org/"
    "https://ezkea.cachix.org"
   ];

    trusted-public-keys = [
     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
     "cache.kabi-binaryserve.org-1:Gsw7yeN4gdWyVJSXP9jnhD0pX9UHp08X9ExcfFHJoCM="
     "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };
};

       
users.extraGroups."nix-serve".members = [ "*" ];

programs.java.enable = true; 

programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
};

  nixpkgs.config = {
   allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-runtime"
   ];
  
  packageOverrides = pkgs: {
  steam = pkgs.steam.override {
     extraPkgs = pkgs: with pkgs; [
       libgdiplus        
      ];
    };
  };
};

 virtualisation = { 
  oci-containers.backend = "podman";
  lxd.enable = true;

 libvirtd = {
  enable = true;   
  onBoot = "ignore";
  onShutdown = "shutdown";

  qemu = {
   runAsRoot = false;
   package = pkgs.qemu_full;
   swtpm.enable = true;
     
  ovmf = {
   enable = true;
   packages = [ pkgs.OVMFFull.fd ];
    };
  };  
};

   podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
 };
}
