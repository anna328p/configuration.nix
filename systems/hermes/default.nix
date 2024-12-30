{ pkgs, lib, localModules, flakes, ... }:
{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.physical
        common.workstation
        common.misc.amd

        flakes.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen5
        ./disks.nix
    ];

    boot = {
        zfs.package = pkgs.zfs_unstable;

        kernelPackages = pkgs.linuxPackages_6_11;

        kernelParams = [
            # for power management
            "pcie_aspm=force"

            # disable PSR2 Selective Updates due to visual glitches
            "amdgpu.dcdebugmask=0x200"
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

    # hardware support

    # run electron apps under wayland for hidpi support
    environment.variables.NIXOS_OZONE_WL = "1";

    # save power
    hardware.bluetooth.powerOnBoot = false;

    # nfc
    services.neard.enable = true;

    # fingerprint reader
    services.fprintd.enable = true;

    # power saving
    powerManagement = {
        enable = true;
        powertop.enable = true;

        cpuFreqGovernor = "schedutil";
    };

    environment.systemPackages = [ pkgs.powertop ];

    services.postgresql = {
        enable = true;

        ensureUsers = [
            {
                name = "anna";
                ensureClauses = {
                    login = true;
                    superuser = true;
                };
            }
        ];
    };

    intransience.datastores.system.byPath."/var/lib".dirs = [
        "fprint"
        "postgresql"
    ];

    home-manager.users.anna.imports = [ ./home ];

    system.stateVersion = "24.11";
}