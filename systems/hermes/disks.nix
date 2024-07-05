{ localModules, ... }:

let
    devs = {
        boot = "/dev/disk/by-uuid/EE41-5915";
        swap = "/dev/disk/by-uuid/32f7549b-4744-4c8f-a6a1-9179eaec338a";
    };
in {
    imports = let
        inherit (localModules) common;
    in [
        common.impermanent
    ];

    # impermanence
    environment.persistence = {
        system.persistentStoragePath = "/safe/system";
        home.persistentStoragePath = "/safe/home";
        cache.persistentStoragePath = "/volatile/cache";
    };

    intransience.datastores = {
        system.path = "/safe/system";
        home.path = "/safe/home";
        cache.path = "/volatile/cache";
    };

    fileSystems = let
        dataset = subpath: {
            fsType = "zfs";
            device = "rpool/encrypt/${subpath}";
            neededForBoot = true;
        };
    in {
        # EFI System Partition
        "/boot" = { device = devs.boot; };

        # Nix store
        "/nix" = dataset "volatile/nix";

        # Persistent data
        "/safe/system" = dataset "safe/system";
        "/safe/home" = dataset "safe/home";

        "/volatile/cache" = dataset "volatile/cache";
        "/volatile/steam" = dataset "volatile/steam";
    };

    swapDevices = [
        { device = devs.swap; }
    ];
}