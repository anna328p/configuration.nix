{ pkgs, ... }:

{
    networking = rec {
        enableIPv6 = true;
        domain = "lan.ap5.network";
        search = [ domain ];
    };

    services = {
        # enable sshd everywhere
        openssh.enable = true;

        openssh.hostKeys = [
            {
                path = "/var/opt/sshd/ssh_host_ed25519_key";
                type = "ed25519";
            }

            {
                path = "/var/opt/sshd/ssh_host_rsa_key";
                type = "rsa";
                bits = 4096;
            }
        ];

        # use systemd-resolved
        resolved = {
            enable = true;
            llmnr = "false";

            fallbackDns = [
                "1.1.1.1"
                "1.0.0.1"
            ];
        };
    };

    environment.systemPackages = let p = pkgs; in [
        ## Networking
        p.speedtest-cli
        p.wget
        p.nmap p.dnsutils p.whois

        # Misc
        p.rsync
    ];
}