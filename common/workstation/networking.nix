{ lib, config, pkgs, ... }:

{
    networking = {
        networkmanager = {
            enable = true;

            # Modern, more reliable wifi stack
            # wifi.backend = "iwd";
            # TODO: breaks authentication

            # Fix auth issues
            wifi.scanRandMacAddress = false;

            dns = "systemd-resolved";
        };

        # Just gets in the way on workstations
        firewall.enable = false;
    };

    users.users.anna.extraGroups = [ "networkmanager" "dialout" ];

    services = {
        # mDNS network discovery/advertisement
        avahi = {
            enable = true;
            ipv6 = true;
            nssmdns4 = true;

            publish = {
                enable = true;
                workstation = true;
                userServices = true;
                hinfo = true;
                domain = true;
            };
        };

        mullvad-vpn = lib.mkIf config.misc.buildFull {
            enable = true;
            package = pkgs.mullvad-vpn;
        };

        # Private LAN VPN
        zerotierone = {
            enable = true;
            joinNetworks = [
                "abfd31bd4777d83c" # annanet
                "abfd31bd479dc978" # linda
                "565799d8f678b97f" # mcserver
            ];
        };

        syncthing = {
            enable = true;
            user = "anna";
            dataDir = "/home/anna";
            configDir = "/home/anna/.config/syncthing";
        };
    };

    environment.etc = {
        mullvad-vpn = lib.mkIf config.misc.buildFull {
            source = "/var/opt/mullvad-vpn";
            mode = "symlink";
        };

        avahi = {
            source = "/var/opt/avahi";
            mode = "symlink";
        };

        "NetworkManager/system-connections" = {
            source = "/var/opt/NetworkManager/system-connections";
            mode = "symlink";
        };
    };

    systemd = {
        tmpfiles.settings."91-var-opt" = {
            "/var/opt/avahi".d = {
                user = "root";
                group = "root";
                mode = "0755";
            };

            "/var/opt/mullvad-vpn".d = {
                user = "root";
                group = "root";
                mode = "0700";
            };

            "/var/opt/NetworkManager/system-connections".d = {
                user = "root";
                group = "root";
                mode = "0700";
            };
        };

        # Reduce startup delay
        services.NetworkManager-wait-online.enable = false;
        network.wait-online.enable = false;
    };
}