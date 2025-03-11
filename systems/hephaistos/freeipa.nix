{ lib, ... }:

{
    systemd.tmpfiles.rules = [
        "d /var/opt/freeipa 0755 root root"
    ];

    networking.macvlans = {
        macvlan-ds1 = { interface = "enp0s31f6"; mode = "bridge"; };
    };

    virtualisation.oci-containers.containers.freeipa = {
        hostname = "ds1.ipa.ap5.network";

        image = "quay.io/freeipa/freeipa-server:rocky-9";

        extraOptions = [
            "--dns=127.0.0.1"
        ];

        volumes = [ "/var/opt/freeipa:/data:Z" ];

        autoStart = false;
    };

    networking.firewall = {
        allowedUDPPorts = [ 53 88 123 464 ];
        allowedTCPPorts = [ 80 443 88 464 389 636 ];
    };

    intransience.datastores.system.byPath."/var/opt".dirs = [ "freeipa" ];
}