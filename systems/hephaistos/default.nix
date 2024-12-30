{ lib, flakes, localModules, ... }:

{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.physical
        common.server

        ./disks.nix

        common.misc.ftp

        ./freeipa.nix
    ];

    nixpkgs.hostPlatform = lib.systems.examples.gnu64;

    system.etc.overlay.enable = false;

    networking = {
        hostName = "hephaistos";
        hostId = "a9ff4923";
    };

    misc.uuid = "cf51a7f4-c533-4d64-a7ce-034ea9ff4923";

    time.timeZone = "Etc/UTC";

    system.stateVersion = "24.11";
}