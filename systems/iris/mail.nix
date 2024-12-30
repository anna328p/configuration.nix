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

        extraVirtualAliases = let
            adminEmail = "anna@dk0.us";
        in {
            "abuse@dk0.us" = adminEmail;
            "postmaster@dk0.us" = adminEmail;

            "abuse@ap5.dev" = adminEmail;
            "postmaster@ap5.dev" = adminEmail;

            "abuse@ap5.network" = adminEmail;
            "postmaster@ap5.network" = adminEmail;

            "pds@ap5.network" = adminEmail;
        };

        loginAccounts = {
            "anna@dk0.us" = {
                hashedPassword = "$6$CCzOD1GSxbY75Bb8$nAu9br071fzS27RVa487Lgie7DnWYfRR81YUX66GViP3ri1/HWmlQo62RDRljDfEuSyU.ZIhJsMT0qMrafc4p0";
                aliases = [ "me@dk0.us" "anna@ap5.dev" ];
            };

            "no-reply-at@ap5.network" = {
                hashedPassword = "$6$qyygSrwfW1q1dh7C$T8bDq6wbE8uCWiPvPz4tUnrMj9OELxBNmyunuWYDeO/Jskrjbpt2Hf/3kOYWjUhRX4nZPnQP8QrHUKsK7ejm0/";
                sendOnly = true;
            };
        };

        certificateScheme = "acme-nginx";
        enableImap = true;
        enableImapSsl = true;

        enableManageSieve = true;

        fullTextSearch = {
            enable = true;
            indexAttachments = true;
            memoryLimit = 256;
        };
    };

    services.postfix.config = {
        smtp_bind_address = "172.16.1.121";
        smtp_helo_name = config.mailserver.sendingFqdn;
    };
}