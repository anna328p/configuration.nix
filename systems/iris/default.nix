{ lib, localModules, ... }:

{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.server
        common.virtual

        ./hardware-configuration.nix
        ./networking.nix
        ./mail.nix
        ./vpn.nix
    ];

    time.timeZone = "Etc/UTC";

    nixpkgs.hostPlatform = lib.systems.examples.gnu64;

    networking.hostName = "iris";

    system.stateVersion = "20.03";
}