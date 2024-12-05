{ pkgs, ... }:

let
    ip = "${pkgs.iproute2}/bin/ip";
in
{
    networking.firewall.allowedUDPPorts = [ 51820 ];

    networking.wireguard = {
        enable = true;

        interfaces.wg0 = {
            ips = [
                "172.16.1.121/32"
                "10.254.0.3/24"
            ];

            allowedIPsAsRoutes = false;

            listenPort = 51820;
            privateKeyFile = "/var/opt/wireguard/wg0-privkey";

            postSetup = ''
                ${ip} rule add from 172.16.1.121/32 priority 42 table 23
                ${ip} rule add oif wg0 table 23

                ${ip} route add default dev wg0 table 23
            '';

            postShutdown = ''
                ${ip} rule del from 172.16.1.121/32 priority 42 table 23
                ${ip} rule del oif wg0 table 23

                ${ip} route del default dev wg0 table 23
            '';

            peers = [
                {
                    publicKey = "ZpS/J6xWsrW/qGLgtsRv/SImvLwIYyQhe8z8+/9kWFc=";
                    allowedIPs = [ "0.0.0.0/0" ];
                    endpoint = "heracles.oci.ap5.network:51820";
                    persistentKeepalive = 25;
                }
            ];
        };
    };
}