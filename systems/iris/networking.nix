{ lib, ... }:

{
    # This file was populated at runtime with the networking
    # details gathered from the active system.

    networking = {
        nameservers = [ "8.8.8.8" "8.8.4.4" ];

        defaultGateway = "10.240.0.1";
        dhcpcd.enable = false;
        usePredictableInterfaceNames = lib.mkForce true;

        interfaces.ens4 = {
            ipv4.addresses = [ { address = "10.240.0.2"; prefixLength = 32; } ];
            ipv4.routes    = [ { address = "10.240.0.1"; prefixLength = 32; } ];
        };
    };

    services.udev.extraRules = ''
        ATTR{address}=="42:01:0a:f0:00:02", NAME="ens4"
    '';
}
