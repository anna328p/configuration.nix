{ lib, localModules, ... }:

{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.server
        common.virtual

        ./hardware-configuration.nix
        ./qbot.nix
        ./vpn.nix
        ./acme.nix
        ./nginx.nix
        ./pds.nix
        ./postgresql.nix
    ];

    nixpkgs.hostPlatform = lib.systems.examples.aarch64-multiplatform;

    time.timeZone = "Etc/UTC";

    networking = {
        hostName = "heracles";

        firewall.allowedTCPPorts = [ 4567 ];
    };

    system.stateVersion = "23.05";
}