{ config, localModules, lib, modulesPath, ... }:

{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.physical
        common.workstation

        "${modulesPath}/profiles/all-hardware.nix"
    ];

    networking = {
        hostName = "generic";
        hostId = "91f98e5d";
    };

    virtualisation.libvirtd.enable = lib.mkForce false;

    time.timeZone = "Etc/UTC";

    boot.kernelParams = [
        "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    ];

    misc.uuid = "91f98e5d-dee5-4851-98df-6409bfca1adf";

    boot.initrd.systemd.enable = lib.mkForce false;
    system.etc.overlay.enable = lib.mkForce false;

    users.users.root.hashedPassword = lib.mkForce "";

    nixpkgs.hostPlatform = lib.systems.examples.gnu64;
}