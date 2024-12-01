{ pkgs, ... }:

let
    ip = "${pkgs.iproute2}/bin/ip";
in
{
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking = {
        firewall.allowedUDPPorts = [ 51820 ];

        wireguard.enable = true;
        wireguard.interfaces = {
            wg0 = {
                ips = [ "10.254.0.2/24" ];
                listenPort = 51820;
                privateKeyFile = "/var/opt/wireguard/wg0-privkey";

                postSetup = ''
                    # pass all traffic to 10.0.0.0/9 through wg0
                    ${ip} route add 10.0.0.0/9 via 10.254.0.1
                    ${ip} route add 10.254.0.1/32 via 10.254.0.1
                '';

                postShutdown = ''
                    ${ip} route del 10.0.0.0/9 via 10.254.0.1
                    ${ip} route del 10.254.0.1/32 via 10.254.0.1
                '';

                peers = [
                    {
                        publicKey = "RC+e/wxNLPha7qn5V9WBuSAWp7SD+u+nGcoH3pB4IEA=";
                        allowedIPs = [ "10.254.0.1/32" "10.0.0.0/9" ];
                        endpoint = "gateway.ap5.network:51821";
                        persistentKeepalive = 25;
                    }
                ];
            };
        };
    };
}