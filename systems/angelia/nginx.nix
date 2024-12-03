{ localModules, ... }:

{
    imports = [
        localModules.common.nginx-base
    ];

    services.nginx.virtualHosts = {
        synapse_api = {
            serverName = "synapse.srv.ap5.network";

            enableACME = true;
            forceSSL = true;

            locations."/".extraConfig = ''
                return 404;
            '';

            locations."/_matrix" = {
                proxyPass = "http://[::1]:8008";
            };
        };

        synapse_federation = {
            serverName = "synapse.srv.ap5.network";
            useACMEHost = "synapse.srv.ap5.network";

            onlySSL = true;

            listen = [ { addr = "0.0.0.0"; port = 8448; ssl = true; } ];

            locations."/" = {
                proxyPass = "http://[::1]:8008";
            };
        };
    };
}