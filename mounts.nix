{ config, lib, pkgs, modulesPath, ... }:
{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/69ce7f2f-dbcb-4fb3-91aa-a07f16a14ab1";
      fsType = "btrfs";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/1BA9-C072";
      fsType = "vfat";
    };

  fileSystems."/media/raid5" =
    { device = "/dev/sda";
      fsType = "btrfs";
    };

  fileSystems."/media/ssd" =
    { device = "/dev/disk/by-uuid/cec96566-f280-475b-a089-1413f7155afc";
      fsType = "btrfs";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/cec96566-f280-475b-a089-1413f7155afc";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/var/lib/containers" =
    { device = "/dev/sda";
      fsType = "btrfs";
      options = [ "subvol=@containers" ];
    };

  fileSystems."/var/lib/libvirt" =
    { device = "/dev/sda";
      fsType = "btrfs";
      options = [ "subvol=@libvirt" ];
    };

  fileSystems."/var/lib/lxc" =
    { device = "/dev/sda";
      fsType = "btrfs";
      options = [ "subvol=@lxc" ];
    };

  fileSystems."/home/kabi/Documents" =
    { device = "/dev/sda";
      fsType = "btrfs";
      options = [ "subvol=@Documents" ];
    };

  fileSystems."/home/kabi/Downloads" =
    { device = "/dev/sda";
      fsType = "btrfs";
      options = [ "subvol=@Downloads" ];
    };

  fileSystems."/home/kabi/Pictures" =
    { device = "/dev/sda";
      fsType = "btrfs";
      options = [ "subvol=@Pictures" ];
    };

  fileSystems."/home/kabi/Music" =
    { device = "/dev/sda";
      fsType = "btrfs";
      options = [ "subvol=@Music" ];
    };

  fileSystems."/home/kabi/Videos" =
    { device = "/dev/sda";
      fsType = "btrfs";
      options = [ "subvol=@Videos" ];
    };

  fileSystems."/home/kabi/Torrents" =
    { device = "/dev/sda";
      fsType = "btrfs";
      options = [ "subvol=@Torrents" ];
    };

  swapDevices = [ ];
}
