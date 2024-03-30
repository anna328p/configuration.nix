{ config, pkgs, lib, localModules, ... }:

{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.server
        common.physical
    ];

    nixpkgs.hostPlatform = lib.systems.examples.gnu64;

    boot.loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = false;
    };

    networking = {
        hostName = "leonardo";

        firewall = {
            # vsftpd, nginx
            allowedTCPPorts = [ 21 80 443 4567 ];

            # vsftpd
            allowedTCPPortRanges = [ { from = 51000; to = 51999; } ];
        };
    };

    system.stateVersion = "19.09";
}