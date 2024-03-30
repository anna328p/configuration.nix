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
    ];

    nixpkgs.hostPlatform = lib.systems.examples.aarch64-multiplatform;

    networking = {
        hostName = "heracles";

        firewall.allowedTCPPorts = [ 4567 ];
    };

    system.stateVersion = "23.05";
}