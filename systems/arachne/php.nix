{ pkgs, config, lib, ... }:

{
    services.phpfpm = let
        php = pkgs.php82;

        phpEnv = php.buildEnv {
            extensions = { enabled, all }:
                enabled ++ [ all.imagick all.opcache ];

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
}