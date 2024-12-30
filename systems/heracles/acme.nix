{ lib, config, ... }:

let
    oracleCert = domain: {
        inherit domain;
        dnsProvider = "oraclecloud";
        credentialsFile = "/var/opt/acme/oraclecloud.env";
        group = config.services.nginx.group;
    };
in {
    security.acme.certs."at.ap5.network" = oracleCert "at.ap5.network";
    security.acme.certs."wildcard-at.ap5.network" = oracleCert "*.at.ap5.network";

    security.acme.certs.psql = (oracleCert "psql.srv.ap5.network") // {
        postRun = ''
            chown postgres:postgres *
            ln -sf $PWD/cert.pem ~postgres/server.crt
            ln -sf $PWD/key.pem ~postgres/server.key
        '';
    };

    systemd.services.acme-fixperms.enable = lib.mkForce false;
}