{ config, ... }:

{
    services.samba = {
        enable = true;

        settings.global = {
            workgroup = "WORKGROUP";
            "server string" = config.networking.hostName;
            "netbios name" = config.networking.hostName;

            security = "user";

            "use sendfile" = "yes";
            "max protocol" = "smb2";

            "hosts allow" = "10.0.0.0/8 127.0.0.1 localhost";
            "hosts deny" = "0.0.0.0/0";

            "guest account" = "nobody";
            "map to guest" = "bad user";
        };

        settings.media = {
            path = "/media/storage";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
        };
    };

    services.samba-wsdd.enable = true;
}