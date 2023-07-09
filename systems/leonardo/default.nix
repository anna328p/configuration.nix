{ config, pkgs, lib, localModules, ... }:

{
    imports = with localModules; [
        common.base
        common.server
        common.virtual

        ./hardware-configuration.nix
        ./networking.nix

        common.misc.ftp
    ];

    nixpkgs.hostPlatform = lib.systems.examples.gnu64;

    networking = {
        hostName = "leonardo";

        firewall.allowedTCPPorts = [ 80 443 ];
    };

    services = {
        nginx = {
            enable = true;
            # Use recommended settings
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            recommendedProxySettings = true;
            recommendedTlsSettings = true;

            # Only allow PFS-enabled ciphers with AES256
            sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

            commonHttpConfig = ''
                map $scheme $hsts_header {
                    https   "max-age=3600; includeSubdomains";
                }
                add_header Strict-Transport-Security $hsts_header;
                add_header 'Referrer-Policy' 'origin-when-cross-origin';
                # add_header X-Content-Type-Options nosniff;
                # add_header X-XSS-Protection "1; mode=block";
                proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
            '';

            virtualHosts = let
                base = root: locations: {
                    inherit root locations;
                    forceSSL = true;
                    enableACME = true;
                    http2 = true;
                };

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

                redirect = dest: {
                    enableACME = true;
                    addSSL = true;
                    globalRedirect = dest;
                };

            in {
                ### CONFIG START ###

                "dk0.us" = base "/var/www/dk0.us" { };

                "ap5.network" = let
                    serverJSON = builtins.toJSON {
                        "m.server" = "synapse.angelia.ap5.network:443";
                    };

                    clientJSON = builtins.toJSON {
                        "m.homeserver" = { "base_url" = "https://synapse.angelia.ap5.network"; };
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

                "mail.dk0.us" = php pkgs.rainloop-community {
                    "^~ /data".extraConfig = "deny all;";
                };

                "boards.inexpensivecomputers.net" =
                    php "/var/www/boards.inexpensivecomputers.net" {};

                "b.inexcomp.com" = redirect "boards.inexpensivecomputers.net";

                "leonardo.dk0.us" = base "/var/www/leonardo.dk0.us" {};
                "nixnest.org" = base "/var/www/nixnest.org" {};

                "_" = { root = "/var/www/leonardo.dk0.us"; };
            };

            appendHttpConfig = ''
                error_log stderr;
                access_log syslog:server=unix:/dev/log combined;
            '';
        };

        mysql = {
            enable = true;
            package = pkgs.mariadb;
            ensureDatabases = [ "boards" "iot" ];
            ensureUsers = [
                { name = "nobody"; ensurePermissions = {
                    "boards.*" = "ALL PRIVILEGES";
                    "iot.*"    = "ALL PRIVILEGES";
                }; }
                { name = "anna";   ensurePermissions = { "iot.*" = "ALL PRIVILEGES"; }; }
                { name = "root";   ensurePermissions = { "*.*"   = "ALL PRIVILEGES"; }; }
            ];
        };

        phpfpm = let 
            php = pkgs.php82;

            phpEnv = php.buildEnv {
                extensions = { enabled, all }: enabled ++ (with all; [
                    imagick opcache
                ]);

                extraConfig = ''
                    upload_max_filesize = 128M
                    post_max_size = 128M
                    max_file_uploads = 65535
                '';
            };

            binPath = lib.makeBinPath [ phpEnv ];

        in {
            phpPackage = phpEnv;

            pools.mypool = {
                user = "nobody";

                settings = {
                    "listen.owner" = config.services.nginx.user;

                    "pm" = "dynamic";
                    "pm.max_children" = 5;
                    "pm.start_servers" = 2;
                    "pm.min_spare_servers" = 1;
                    "pm.max_spare_servers" = 3;
                    "pm.max_requests" = 500;

                    "php_admin_value[error_log]" = "stderr";
                    "php_admin_flag[log_errors]" = true;

                    "catch_workers_output" = true;
                };

                phpEnv."PATH" = binPath;
            };
        };
    };

    system.stateVersion = "19.09";
}
