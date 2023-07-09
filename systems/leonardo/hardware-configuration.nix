{ ... }:

{
    boot.loader = {
        grub = {
            device = "/dev/sda";
            efiSupport = true;
        };
        efi = {
            efiSysMountPoint = "/boot/efi";
            canTouchEfiVariables = false;
        };
    };

    boot.initrd.secrets = {};

    fileSystems = {
        "/"         = { device = "/dev/sda1";  fsType = "ext4"; };
        "/boot/efi" = { device = "/dev/sda15"; fsType = "vfat"; };
    };

    swapDevices = [
        { device = "/var/swapfile"; }
    ];
}
