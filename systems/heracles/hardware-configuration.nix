{ ... }:

{
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  boot.initrd.kernelModules = [ "nvme" ];

  fileSystems."/" = { device = "/dev/sda3"; fsType = "xfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/E6D6-572B"; fsType = "vfat"; };
}
