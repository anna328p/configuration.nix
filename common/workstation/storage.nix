{ lib, config, ... }:

let
    kernelPackages = lib.mkDefault
        config.boot.zfs.package.latestCompatibleLinuxPackages;
in {
    boot = {
        inherit kernelPackages;

        supportedFilesystems = [
            "zfs"

            # external drives
            "ntfs" "exfat"
        ];

        initrd = {
            kernelModules = [ "dm-snapshot" ];
            supportedFilesystems = [ "zfs" ];
        };
    };
}