{ ... }:

{
    services.nginx = {
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

        appendHttpConfig = ''
            error_log stderr;
            access_log syslog:server=unix:/dev/log combined;
        '';
    };
}