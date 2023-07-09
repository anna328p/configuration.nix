{ config, lib, flakes, modulesPath, ... }:

let
    devs = let
        by-uuid = uuid: "/dev/disk/by-uuid/${uuid}";
    in {
        boot = by-uuid "3D04-D640";
        root = by-uuid "edcdb9c3-c01c-4d52-be10-d19879553f91";
        home = by-uuid "0d52b88d-3955-42b5-b091-6f8ffc3452ae";
        storage = by-uuid "d54cf5fb-f74d-46f1-9a2b-001c07fdb422";

        backup = by-uuid "aad5ac37-057e-4f18-88ff-81632eefe237";
        backup2 = by-uuid "56cd0ce4-63a1-4146-873c-b565a19f5d10";

        swap = by-uuid "dc871ccb-2841-4b41-95dc-184fe08e3c77";
    };

in {
    imports = with flakes.nixos-hardware.nixosModules; [
        common-pc-ssd common-cpu-amd common-gpu-amd
    ];

    hardware.amdgpu.opencl = config.misc.buildFull;

    fileSystems = let
        btrfsEntry = device: options': {
            inherit device;
            fsType = "btrfs";
            options = [ "compress=zstd" ] ++ options';
            noCheck = true;
        };

        storageOpts =
            [ "nofail" "noauto" "x-systemd.automount" "compress-force=zstd" ];

    in {
        "/" = btrfsEntry devs.root [];

        "/boot" = { device = devs.boot; };

        "/media/storage" = btrfsEntry devs.storage storageOpts;
        "/media/backup" = btrfsEntry devs.backup storageOpts;
        "/media/backup2" = btrfsEntry devs.backup2 storageOpts;

        "/home" = btrfsEntry devs.home [ "subvol=@home" ];
        "/media/games" = btrfsEntry devs.home [ "subvol=@games" ];
        "/media/raw-home" = btrfsEntry devs.home [ "subvol=/" ];
    };

    swapDevices = [
        { device = devs.swap; }
    ];

    nix.settings.max-jobs = 24;
    powerManagement.cpuFreqGovernor = "performance";
}
