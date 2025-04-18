{ localModules, flakes, lib, ... }:

{
    imports = [
        flakes.intransience.nixosModules.default

        ./system.nix
        ./home.nix
    ];

    # tmpfs on root
    fileSystems."/" = {
        fsType = "tmpfs";
        options = [ "size=100%" "huge=within_size" ];
    };

    intransience.enable = true;

    intransience.datastores = {
        system.path = lib.mkDefault null;
        home.path = lib.mkDefault null;
        cache.path = lib.mkDefault null;
    };
}