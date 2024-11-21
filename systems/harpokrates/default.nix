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
        hostName = "harpokrates";
    };

    system.stateVersion = "24.11";
}