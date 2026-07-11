{ lib, pkgs, ... }:

{
    boot = {
        kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

        supportedFilesystems = [
            "zfs"

            # external drives
            "ntfs" "exfat"
        ];

        initrd = {
            kernelModules = [ "dm-snapshot" ];
            supportedFilesystems = [ "zfs" ];
        };

        zfs.forceImportRoot = false;
    };
}