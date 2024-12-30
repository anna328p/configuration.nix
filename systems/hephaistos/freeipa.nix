{ ... }:

{
    systemd.tmpfiles.rules = [
        "d /var/opt/freeipa 0755 root root"
    ];

    virtualisation.oci-containers.containers.freeipa = {
        image = "quay.io/freeipa/freeipa-server:rocky-9";

        volumes = [ "/var/opt/freeipa:/data:Z" ];

        autoStart = false;
    };

    networking.firewall = {
        allowedUDPPorts = [ 53 88 464 ];
        allowedTCPPorts = [ 80 443 88 464 389 636 ];
    };

    intransience.datastores.system.byPath."/var/opt".dirs = [ "freeipa" ];
}