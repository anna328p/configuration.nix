{ flakes, lib, ... }:

{
    imports = [
        flakes.impermanence.nixosModule

        ./system.nix
        ./home.nix
    ];

    # tmpfs on root
    fileSystems."/" = {
        fsType = "tmpfs";
        options = [ "size=100%" "huge=within_size" ];
    };

    environment.persistence = {
        system = {
            hideMounts = true;
            persistentStoragePath = lib.mkDefault null;
        };

        home = {
            hideMounts = true;
            persistentStoragePath = lib.mkDefault null;
        };

        cache = {
            hideMounts = true;
            persistentStoragePath = lib.mkDefault null;
        };
    };
}