{ config, ... }:

{
    services.nginx = {
        enable = true;

        virtualHosts = {
            "theseus.lan.ap5.network" = {
                root = "/srv/http/theseus";

                locations."/".extraConfig = ''
                    autoindex on;
                '';
            };
        };
    };

    systemd.tmpfiles.settings."90-nginx" = let
        default = {
            inherit (config.services.nginx) user group;
        };
    in {
        "/srv/http/theseus".d = default // {
            mode = "0777";
        };

        "/srv/http/theseus/torrents".L = default // {
            argument = "/media/storage/torrents";
            mode = "0777";
        };
    };
}