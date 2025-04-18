{ ... }:

{
    mailserver.loginAccounts = {
        "anna@dk0.us" = {
            hashedPassword = "$6$CCzOD1GSxbY75Bb8$nAu9br071fzS27RVa487Lgie7DnWYfRR81YUX66GViP3ri1/HWmlQo62RDRljDfEuSyU.ZIhJsMT0qMrafc4p0";
            aliases = [ "me@dk0.us" "anna@ap5.dev" ];
        };

        "no-reply-at@ap5.network" = {
            hashedPassword = "$6$qyygSrwfW1q1dh7C$T8bDq6wbE8uCWiPvPz4tUnrMj9OELxBNmyunuWYDeO/Jskrjbpt2Hf/3kOYWjUhRX4nZPnQP8QrHUKsK7ejm0/";
            sendOnly = true;
        };

        "printer@ap5.network" = {
            hashedPassword = "$6$4HOnOyyypJoOdYgz$nPIpxsMHnIIOWpGJ8fXSpLh.6X977MjllcgfHL9BBRXICk3yRm6hMtzmPieHKqO65GA4GxQomZchQykmgeKxY.";
        };
    };

    mailserver.extraVirtualAliases = let
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
}