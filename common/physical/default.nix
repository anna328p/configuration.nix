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

    environment.systemPackages = with pkgs; [
        acpi

        # Query hardware configuration
        usbutils
        pciutils
        dmidecode

        # Sensors
        lm_sensors

        # Firmware integration
        efibootmgr
    ];

    hardware.enableRedistributableFirmware = true;

    services.gpm.enable = true;
}