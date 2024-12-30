{ lib, config, ... }:

let
    certDir = config.security.acme.certs.psql.directory;

    certFile = "${certDir}/cert.pem";
    keyFile = "${certDir}/key.pem";

    caDir = "/var/opt/postgresql/ca";
    caFile = "${caDir}/ca.pem";
in {
    systemd.tmpfiles.rules = [
        "d ${caDir} 0700 postgres nogroup"
    ];

    services.postgresql = {
        enable = true;

        ensureDatabases = [ "synapse" ];

        authentication = lib.mkOverride 10 ''
            #type    db   user  address    method
            local    all  all              trust
            hostssl  all  all   0.0.0.0/0  cert
            hostssl  all  all   ::1/0      cert
        '';

        enableTCPIP = true;

        settings = {
            ssl = true;
            ssl_cert_file = certFile;
            ssl_key_file = keyFile;
            ssl_ca_file = caFile;
        };

        ensureUsers = [
            {
                name = "synapse";
                ensureClauses.login = true;
                ensureDBOwnership = true;
            }
        ];
    };
}