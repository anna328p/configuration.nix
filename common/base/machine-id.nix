{ lib, config, ... }:

let
    inherit (builtins) pathExists;
    inherit (lib) mkIf;
in {
    environment.etc.machine-id = let
        idFile = ../../secrets/machine-id/${config.networking.hostName};
    in mkIf (pathExists idFile) {
        mode = "0444";
        source = idFile;
    };
}