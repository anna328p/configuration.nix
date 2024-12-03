{ config, pkgs, localModules, local-lib, ... }:

{
    imports = [
        localModules.common.nginx-base
    ];

    services.nginx.virtualHosts = let
        inherit (local-lib.nginx) base redirect;

        php = root: locations': let
            nginxPackage = config.services.nginx.package;
            phpSocket = config.services.phpfpm.pools.mypool.socket;

            locations = {
                "/" = {
                    tryFiles = "$uri $uri/ /index.php$is_args$args";
                    index = "index.php index.html";
                };

                "~ \\.php$".extraConfig = ''
                    include ${nginxPackage}/conf/fastcgi.conf;
                    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                    fastcgi_pass  unix:${phpSocket};
                    fastcgi_index index.php;
                '';
            };
        in
            base root (locations // locations');

    in {
        ### CONFIG START ###

        "dk0.us" = base "/var/www/dk0.us" { };

        "ap5.network" = let
            serverJSON = builtins.toJSON {
                "m.server" = "synapse.srv.ap5.network:443";
            };

            clientJSON = builtins.toJSON {
                "m.homeserver" = { "base_url" = "https://synapse.srv.ap5.network"; };
                "m.identity_server" = { "base_url" = "https://vector.im"; };
            };

        in base "/var/www/ap5.network" {
            "= /.well-known/matrix/server".extraConfig = ''
                add_header Content-Type application/json;
                return 200 '${serverJSON}';
            '';

            "= /.well-known/matrix/client".extraConfig = ''
                add_header Content-Type application/json;
                add_header Access-Control-Allow-Origin *;
                return 200 '${clientJSON}';
            '';
        };

        "mail.apps.ap5.network" = php pkgs.rainloop-community {
            "^~ /data".extraConfig = "deny all;";
        };

        "element.apps.ap5.network" = base pkgs.element-web { };

        "boards.inexpensivecomputers.net" =
            php "/var/www/boards.inexpensivecomputers.net" {};

        "b.inexcomp.com" = redirect "boards.inexpensivecomputers.net";

        "_" = { root = "/var/www/arachne.ap5.network"; };
    };
}