{ localModules, ... }:

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
        ./synapse.nix
    ];

    nixpkgs.hostPlatform = lib.systems.examples.gnu64;

    networking = {
        hostName = "angelia";
        firewall.allowedTCPPorts = [ 80 443 ];
    };

    system.stateVersion = "20.03";
}