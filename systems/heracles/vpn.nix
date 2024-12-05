{ pkgs, ... }:

let
    ip = "${pkgs.iproute2}/bin/ip";
in
{
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = 1;
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

    networking.firewall.allowedUDPPorts = [ 51820 ];

    networking.wireguard = {
        enable = true;

        # my public key: ZpS/J6xWsrW/qGLgtsRv/SImvLwIYyQhe8z8+/9kWFc=
        interfaces.wg0 = {
            ips = [ "10.254.0.2/24" ];

            listenPort = 51820;
            privateKeyFile = "/var/opt/wireguard/wg0-privkey";

            postSetup = ''
                # pass all traffic to 10.0.0.0/9 through wg0
                ${ip} route add 10.0.0.0/9 via 10.254.0.1
                ${ip} route add 10.254.0.1/32 via 10.254.0.1
                ${ip} route add 172.16.1.121/32 dev wg0
            '';

            postShutdown = ''
                ${ip} route del 10.0.0.0/9 via 10.254.0.1
                ${ip} route del 10.254.0.1/32 via 10.254.0.1
                ${ip} route del 172.16.1.121/32 dev wg0
            '';

            peers = [
                {
                    publicKey = "RC+e/wxNLPha7qn5V9WBuSAWp7SD+u+nGcoH3pB4IEA=";
                    allowedIPs = [ "10.254.0.1/32" "10.0.0.0/9" ];
                    endpoint = "gateway.ap5.network:51821";
                    persistentKeepalive = 25;
                }

                {
                    publicKey = "4Ic2lkGclLZe0FOCa59IZ8XKgT1khvGk3ej1UyqgySw=";
                    allowedIPs = [
                        "172.16.1.121/32"
                        "10.254.0.3/32"
                    ];
                    endpoint = "iris.gcloud.ap5.network:51820";
                    persistentKeepalive = 25;
                }
            ];
        };
    };
}