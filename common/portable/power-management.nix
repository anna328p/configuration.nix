{ pkgs, lib, ... }:

{
    boot.kernelParams = [ "pcie_aspm=force" ];

    hardware.bluetooth.powerOnBoot = false;

    powerManagement = {
        enable = true;
        powertop.enable = true;
    };

    services.tuned.enable = true;
    services.tlp.enable = lib.mkForce false;

    environment.systemPackages = [ pkgs.powertop ];
}