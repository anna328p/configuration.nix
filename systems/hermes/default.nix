{ pkgs, lib, localModules, flakes, ... }:
{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.physical
        common.workstation
        common.misc.amd

        flakes.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
        ./disks.nix
    ];

    boot = {
        zfs.package = pkgs.zfs_unstable;

        kernelParams = [
            "iwlwifi.swcrypto=0" "bluetooth.disable_ertm=1"
            "pcie_aspm=force"
        ];

        plymouth.enable = lib.mkForce false;
    };

    # identity

    networking = {
        hostName = "hermes";
        hostId = "6a5a4b0b";
    };

    misc.uuid = "46397c55-410c-4b6c-9050-5fbedb77e303";

    time.timeZone = "America/Chicago";

    hardware.bluetooth.powerOnBoot = false;

    powerManagement = {
        enable = true;
        powertop.enable = true;

        cpuFreqGovernor = "schedutil";
    };

    services.postgresql.enable = true;

    home-manager.users.anna.imports = [ ./home ];

    environment.systemPackages = [ pkgs.powertop ];

    system.stateVersion = "22.05";
}