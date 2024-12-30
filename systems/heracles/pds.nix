{ lib, pkgs, ... }:

let
    pdsDataDir = "/var/opt/pds";

    kv = pkgs.formats.keyValue { };

    pdsEnvPublic = kv.generate "pds.env.public" {
        PDS_HOSTNAME = "at.ap5.network";
        PDS_DATA_DIRECTORY = "/pds";
        PDS_BLOB_UPLOAD_LIMIT = 52428800;
        PDS_DID_PLC_URL = "https://plc.directory";
        PDS_BSKY_APP_VIEW_URL = "https://api.bsky.app";
        PDS_BSKY_APP_VIEW_DID = "did:web:api.bsky.app";
        PDS_REPORT_SERVICE_URL = "https://mod.bsky.app";
        PDS_REPORT_SERVICE_DID = "did:plc:ar7c4by46qjdydhdevvrndac";
        PDS_CRAWLERS = "https://bsky.network";
        LOG_ENABLED = true;

        PDS_CONTACT_EMAIL_ADDRESS = "pds@ap5.network";

        PDS_EMAIL_FROM_ADDRESS = "no-reply-at@ap5.network";

        PDS_BLOBSTORE_S3_REGION = "us-ashburn-1";
        PDS_BLOBSTORE_S3_ENDPOINT =
            "https://idydntt5dn6y.compat.objectstorage.us-ashburn-1.oraclecloud.com/";
        PDS_BLOBSTORE_S3_BUCKET = "pds-blobstore";
        PDS_BLOBSTORE_S3_FORCE_PATH_STYLE = true;
    };

    genPrivateEnv = let
        openssl = lib.getExe pkgs.openssl;
        xxd = lib.getExe pkgs.xxd;
    in /* bash */ ''
        if [ -e ${pdsDataDir}/pds.env.private ]; then
            exit 0
        fi

        GENERATE_SECURE_SECRET_CMD="${openssl} rand --hex 16"
        GENERATE_K256_PRIVATE_KEY_CMD="${openssl} ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | ${xxd} --plain --cols 32"

        cat > ${pdsDataDir}/pds.env.private <<-ENV
            PDS_JWT_SECRET=$(eval "''${GENERATE_SECURE_SECRET_CMD}")
            PDS_ADMIN_PASSWORD=$(eval "''${GENERATE_SECURE_SECRET_CMD}")
            PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=$(eval "''${GENERATE_K256_PRIVATE_KEY_CMD}")

            PDS_EMAIL_SMTP_URL=
            
            PDS_BLOBSTORE_S3_ACCESS_KEY_ID=
            PDS_BLOBSTORE_S3_SECRET_ACCESS_KEY=
        ENV
    '';

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

            buildInputs = [ pkgs.openssl ];

            installPhase = ''
                install -d "$out/bin"
                install -d "$out/libexec"

                commands=(account create-invite-code help request-crawl update)

                for name in "''${commands[@]}"; do
                    cp -v "pdsadmin/$name.sh" "$out/libexec/pdsadmin-$name"
                    chmod a+x "$out/libexec/pdsadmin-$name"
                done

                cat > "$out/bin/pdsadmin" <<EOF
                #!/usr/bin/env bash

                set -euo pipefail

                export PATH="${pkgs.openssl}/bin:\$PATH"

                declare -A cmds
                for cmd in ''${commands[@]}; do
                    cmds[\$cmd]="$out/libexec/pdsadmin-\$cmd"
                done

                if (( \$# == 0 )); then
                    exec "\''${cmds[help]}"
                fi

                command="\$1"

                if [[ -v cmds[\$command] ]]; then
                    shift
                    exec "\''${cmds[\$command]}" "\$@"
                else
                    echo "Unknown command: \$command" >&2
                    exit 1
                fi
                EOF

                chmod a+x "$out/bin/pdsadmin"
                '';
        };

in {
    systemd.tmpfiles.rules = [
        "d ${pdsDataDir} 0755 root root"
    ];

    systemd.services.generate-pds-config = {
        serviceConfig.Type = "oneshot";
        wantedBy = [ "podman-pds.service" ];
        script = genPrivateEnv;
    };

    environment.etc = {
        "pds.env.public".source = pdsEnvPublic;
        "pds.env".text = ''
            source /etc/pds.env.public
            source ${pdsDataDir}/pds.env.private
        '';
    };

    environment.variables.PDS_ENV_FILE = "/etc/pds.env";

    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers.pds = {
        image = "ghcr.io/bluesky-social/pds";
        volumes = [ "${pdsDataDir}:/pds" ];
        ports = [ "127.0.0.1:3000:3000" ];

        environmentFiles = [
            "/etc/pds.env.public"
            "${pdsDataDir}/pds.env.private"
        ];
    };

    environment.systemPackages = [ pdsadmin ];
}