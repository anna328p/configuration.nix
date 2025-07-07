{ lib, pkgs, ... }:

let
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
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