{ config, localModules, ... }:

{
    imports = [
        localModules.common.nginx-base
    ];

    services.nginx.virtualHosts = let
        pdsConfig = {
            forceSSL = true;

            locations."/" = {
                proxyPass = "http://127.0.0.1:3000";
                proxyWebsockets = true;
            };

            extraConfig = ''
                keepalive_timeout 0;
            '';
        };
    in {
        base = pdsConfig // {
            serverName = "at.ap5.network";
            useACMEHost = "at.ap5.network";
        };

        wildcard = pdsConfig // {
            serverName = "*.at.ap5.network";
            useACMEHost = "wildcard-at.ap5.network";
        };
    };
}