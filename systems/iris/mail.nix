{ flakes, config, ... }:

{
    imports = [
        flakes.snm.nixosModules.default
    ];

    mailserver = {
        enable = true;

        fqdn = "mail.srv.ap5.network";
        sendingFqdn = "mail-ext.srv.ap5.network";

        domains = [ "dk0.us" "ap5.dev" "ap5.network" ];

        certificateScheme = "acme-nginx";

        enableImap = true;
        enableImapSsl = true;

        enablePop3 = true;
        enablePop3Ssl = true;

        hierarchySeparator = "/";

        enableManageSieve = true;

        fullTextSearch = {
            enable = true;
            memoryLimit = 256;
        };

        policydSPFExtraConfig = ''
            Mail_From_reject = false
        '';
    };

    services.postfix.config = {
        smtp_bind_address = "172.16.1.121";
        smtp_helo_name = config.mailserver.sendingFqdn;
    };

    services.rspamd.extraConfig = ''
        extended_spam_headers = true;
    '';
}