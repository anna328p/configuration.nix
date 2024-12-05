{ flakes, ... }:

{
    imports = [
        flakes.snm.nixosModules.default
    ];

    mailserver = {
        enable = true;
        fqdn = "mail.srv.ap5.network";
        domains = [ "dk0.us" "ap5.dev" ];

        loginAccounts = {
            "anna@dk0.us" = {
                hashedPassword = "$6$CCzOD1GSxbY75Bb8$nAu9br071fzS27RVa487Lgie7DnWYfRR81YUX66GViP3ri1/HWmlQo62RDRljDfEuSyU.ZIhJsMT0qMrafc4p0";
                aliases = [ "me@dk0.us" "anna@ap5.dev" ];
            };
        };

        certificateScheme = "acme-nginx";
        enableImap = true;
        enableImapSsl = true;

        enableManageSieve = true;
    };

    services.postfix.config = {
        smtp_bind_address = "172.16.1.121";
    };
}