{ lib, systemConfig, ... }:

{
    dconf.settings = let
        inherit (lib.hm.gvariant) mkArray type;
    in {
        "org/gnome/shell/extensions/gsconnect" = {
            enabled = true;

            id = systemConfig.misc.uuid;
            name = systemConfig.networking.hostName;

            devices = mkArray type.string [ "83fcaad063080619" ];
        };

        "org/gnome/shell/extensions/gsconnect/device/83fcaad063080619" = {
            name = "aither";
            paired = true;

            certificate-pem = (builtins.readFile ./aither-cert.pem);
        };
    };
}