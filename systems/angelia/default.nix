{ localModules, lib, ... }:

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

    time.timeZone = "Etc/UTC";

    networking = {
        hostName = "angelia";
        domain = "oci.ap5.network";
        firewall.allowedTCPPorts = [ 80 443 ];
    };

    system.stateVersion = "20.03";
}