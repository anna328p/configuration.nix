{ config, localModules, ... }:

let
    oracleCert = domain: {
        inherit domain;
        dnsProvider = "oraclecloud";
        credentialsFile = "/var/opt/acme/oraclecloud.env";
        group = config.services.nginx.group;
    };
in {
    imports = [
        localModules.common.nginx-base
    ];

    security.acme.certs."at.ap5.network" = oracleCert "at.ap5.network";

    security.acme.certs."wildcard-at.ap5.network" = oracleCert "*.at.ap5.network";

    services.nginx.virtualHosts = let
        pdsConfig = {
            forceSSL = true;

            locations."/" = {
                proxyPass = "http://localhost:3000";
                proxyWebsockets = true;
            };
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