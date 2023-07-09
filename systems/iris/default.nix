{ lib, localModules, ... }:

{
    imports = with localModules; [
        common.base
        common.server
        common.virtual

        ./hardware-configuration.nix
        ./networking.nix # generated at runtime by nixos-infect
        ./mail.nix
    ];

    nixpkgs.hostPlatform = lib.systems.examples.gnu64;

    networking.hostName = "iris";

    system.stateVersion = "20.03";
}
