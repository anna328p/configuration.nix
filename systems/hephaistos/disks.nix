{ localModules, ... }:

let
    uuids = {
        boot = "11f5382d-869e-4457-bdb5-f9002e1c505d";
        swap = "548ae092-f991-448e-817f-adaa538c2db9";
    };

    devs = builtins.mapAttrs
        (_: uuid: "/dev/disk/by-partuuid/${uuid}")
        uuids;
in {
    imports = let
        inherit (localModules) common;
    in [
        common.impermanent
    ];

    intransience.datastores = {
        system.path = "/safe/system";
        home.path = "/safe/system/home";
        home.enable = false;
        cache.path = "/volatile/cache";
    };

    fileSystems = let
        dataset = subpath: {
            fsType = "zfs";
            device = "rpool/${subpath}";
            neededForBoot = true;
        };
    in {
        # EFI System Partition
        "/boot" = { device = devs.boot; };

        # Nix store
        "/nix" = dataset "volatile/nix";

        # Persistent data
        "/safe/system" = dataset "safe/system";
        "/volatile/cache" = dataset "volatile/cache";
    };

    swapDevices = [
        { device = devs.swap; }
    ];
}