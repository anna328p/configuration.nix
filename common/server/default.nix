{ modulesPath, ... }:

{
    imports = [
        "${modulesPath}/profiles/headless.nix"
        "${modulesPath}/profiles/minimal.nix"
    ];

    boot.cleanTmpDir = true;

    networking.firewall = {
        allowPing = true;

        allowedTCPPorts = [ 22 ];
        allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
    };

    services.fail2ban.enable = true;

    security.acme = {
        defaults.email = "anna328p+acme@gmail.com";
        acceptTerms = true;
    };

    nix.gc = {
        automatic = true;
        options = "--delete-older-than 14d";
        dates = "weekly";
    };

    system.autoUpgrade.enable = true;
}
