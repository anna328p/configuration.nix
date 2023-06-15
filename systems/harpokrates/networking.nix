{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    defaultGateway = "10.0.1.1";
    dhcpcd.enable = true;
    usePredictableInterfaceNames = lib.mkForce true;
  };
  services.udev.extraRules = ''
    ATTR{address}=="02:00:17:02:20:89", NAME="ens3"
  '';
}
