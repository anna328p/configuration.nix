{ flakes, ... }:

{
    imports = [
        flakes.snm.nixosModules.default
    ];

    services.postfix.config.inet_protocols = "ipv4";

    mailserver = {
        enable = true;
        fqdn = "iris.dk0.us";
        domains = [ "dk0.us" ];

        loginAccounts = {
            "anna@dk0.us" = {
                hashedPassword = "$6$CCzOD1GSxbY75Bb8$nAu9br071fzS27RVa487Lgie7DnWYfRR81YUX66GViP3ri1/HWmlQo62RDRljDfEuSyU.ZIhJsMT0qMrafc4p0";
                aliases = [ "me@dk0.us" ];
            };
        };

        certificateScheme = 3;
        enableImap = true;
        enableImapSsl = true;

        enableManageSieve = true;
    };
}
