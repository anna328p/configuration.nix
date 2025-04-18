{ lib, ... }:

let
    inherit (lib) mkOption types;
in {
    imports = [
        ./udev.nix
        ./rebuilds.nix
        ./bluray.nix
    ];

    options.misc = {
        uuid = mkOption {
            type = types.str;
            description = "System-specific UUID";
        };
    };
}