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
        zfs.package = pkgs.zfsUnstableOld;

        kernelPackages = pkgs.linux610;

        kernelParams = [
            # for power management
            "pcie_aspm=force"

            # disable PSR2 Selective Updates due to visual glitches
            # "amdgpu.dcdebugmask=0x200"

            # disable PSR-SU and PSR due to freezing
            "amdgpu.dcdebugmask=0x410"
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

    # disable font hinting
    fonts.fontconfig.hinting.enable = false;

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

    services.ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        acceleration = "rocm";
        rocmOverrideGfx = "11.0.2";
    };

    intransience.datastores.system.byPath."/var/lib".dirs = [
        "fprint"
        "postgresql"

        { path = "private/ollama"; parentDirectory.mode = "0700"; }
    ];

    home-manager.users.anna.imports = [ ./home ];

    system.stateVersion = "24.11";
}