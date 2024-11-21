{ config, pkgs, lib, localModules, ... }:

{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.server
        common.virtual

        ./hardware-configuration.nix
        ./networking.nix

        ./nginx.nix
        ./mysql.nix
        ./php.nix

        common.misc.ftp
    ];

    nixpkgs.hostPlatform = lib.systems.examples.gnu64;

    time.timeZone = "Etc/UTC";

    networking = {
        hostName = "arachne";
        domain = "oci.ap5.network";

        firewall.allowedTCPPorts = [ 80 443 ];
    };

    system.stateVersion = "19.09";
}