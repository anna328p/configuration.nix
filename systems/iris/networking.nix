{ lib, ... }:

{
    # This file was populated at runtime with the networking
    # details gathered from the active system.

    networking = {
        nameservers = [ "8.8.8.8" "8.8.4.4" ];

        defaultGateway = "10.240.0.1";
        dhcpcd.enable = true;
    };
}