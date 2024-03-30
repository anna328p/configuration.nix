{ config, pkgs, lib, ... }:

{
    imports = [
        ./storage.nix
    ];

    boot.loader = {
        systemd-boot.enable = true;

        efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
        };

        systemd-boot = {
            extraFiles = {
                "efi/shell/shell.efi" = "${pkgs.edk2-uefi-shell}/shell.efi";
            };

            extraEntries = {
                "z-00-efi-shell.conf" = ''
                    title EFI Shell
                    efi /efi/shell/shell.efi
                '';
            };
        };
    };

    environment.systemPackages = let p = pkgs; in [
        p.acpi

        # Query hardware configuration
        p.usbutils
        p.pciutils
        p.dmidecode

        # Sensors
        p.lm_sensors

        # Firmware integration
        p.efibootmgr
    ];

    hardware.enableRedistributableFirmware = true;

    services.gpm.enable = true;
}