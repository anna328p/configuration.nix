{ lib, pkgs, ... }:

let
    kv = pkgs.formats.keyValue { };

    pdsEnvPublic = kv.generate "pds.env.public" {
        PDS_HOSTNAME = "at.ap5.network";
        PDS_DATA_DIRECTORY = "/pds";
        PDS_BLOBSTORE_DISK_LOCATION = "/pds/blocks";
        PDS_BLOB_UPLOAD_LIMIT = 52428800;
        PDS_DID_PLC_URL = "https://plc.directory";
        PDS_BSKY_APP_VIEW_URL = "https://api.bsky.app";
        PDS_BSKY_APP_VIEW_DID = "did:web:api.bsky.app";
        PDS_REPORT_SERVICE_URL = "https://mod.bsky.app";
        PDS_REPORT_SERVICE_DID = "did:plc:ar7c4by46qjdydhdevvrndac";
        PDS_CRAWLERS = "https://bsky.network";
        LOG_ENABLED = true;
    };

    pdsadmin = let
        version = "0.4.74";
    in
        pkgs.stdenv.mkDerivation {
            pname = "pdsadmin";
            inherit version;

            src = pkgs.fetchFromGitHub {
                owner = "bluesky-social";
                repo = "pds";
                rev = "v${version}";

                hash = "sha256-kNHsQ6funmo8bnkFBNWHQ0Fmd5nf/uh+x9buaRJMZnM=";
            };

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
                install -d "$out/bin"

                for name in \
                    account \
                    create-invite-code \
                    help \
                    request-crawl \
                    update;
                do
                    cp -v "pdsadmin/$name.sh" "$out/bin/pdsadmin-$name"
                    chmod a+x "$out/bin/pdsadmin-$name"
                done
            '';
        };

in {
    systemd.tmpfiles.rules = [
        "d /var/opt/pds 0755 root root"
    ];

    systemd.services.generate-pds-config = {
        serviceConfig.Type = "oneshot";

        wantedBy = [ "podman-pds.service" ];

        script = let
            openssl = lib.getExe pkgs.openssl;
            xxd = lib.getExe pkgs.xxd;
        in /* bash */ ''
            if [ -e /var/opt/pds/pds.env.private ]; then
                exit 0
            fi

            GENERATE_SECURE_SECRET_CMD="${openssl} rand --hex 16"
            GENERATE_K256_PRIVATE_KEY_CMD="${openssl} ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | ${xxd} --plain --cols 32"

            cat > /var/opt/pds/pds.env.private <<-ENV
                PDS_JWT_SECRET=$(eval "''${GENERATE_SECURE_SECRET_CMD}")
                PDS_ADMIN_PASSWORD=$(eval "''${GENERATE_SECURE_SECRET_CMD}")
                PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=$(eval "''${GENERATE_K256_PRIVATE_KEY_CMD}")
            ENV
        '';
    };

    environment.etc = {
        "pds.env.public".source = pdsEnvPublic;
        "pds.env".text = ''
            source /etc/pds.env.public
            source /var/opt/pds/pds.env.private
        '';
    };

    environment.variables.PDS_ENV_FILE = "/etc/pds.env";

    virtualisation.oci-containers = {
        backend = "podman";
        
        containers.pds = {
            image = "ghcr.io/bluesky-social/pds";

            volumes = [ "/var/opt/pds:/pds" ];
            environmentFiles = [ "/etc/pds.env.public" "/var/opt/pds/pds.env.private" ];

            ports = [ "127.0.0.1:3000:3000" "[::1]:3000:3000" ];
        };
    };

    environment.systemPackages = [ pdsadmin ];
}