{ pkgs, lib, localModules, L, flakes, ... }:
{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.physical
        common.portable
        common.workstation
        common.misc.amd

        flakes.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen5

        ./disks.nix
    ];

    boot = let
        inherit (builtins) toString;
        inherit (L.units) gibi;

        arcSize = toString (8 * gibi);
    in {
        zfs.package = pkgs.zfs_2_4;

        kernelPackages = pkgs.linuxPackages_7_1;

        # Address OOM lockups
        kernelParams = [ "zfs.zfs_arc_max=${arcSize}" ];

        plymouth.enable = lib.mkForce false;
    };

    # identity

    networking.hostName = "hermes";
    networking.hostId = "6a5a4b0b";

    misc.uuid = "46397c55-410c-4b6c-9050-5fbedb77e303";

    time.timeZone = "America/Chicago";

    # hardware support

    # run electron apps under wayland for hidpi support
    environment.variables.NIXOS_OZONE_WL = "1";

    # disable font hinting
    fonts.fontconfig.hinting.enable = false;

    # nfc
    services.neard.enable = false;

    hardware.nfc-nci = {
        enable = true;
        enableIFD = true;
    };

    # fingerprint reader
    services.fprintd.enable = true;

    # misc

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