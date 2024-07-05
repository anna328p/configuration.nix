{ config, lib, pkgs, ... }:

{
    boot = {
        # Emulate ARM systems for remote deployments
        binfmt.emulatedSystems = lib.optionals config.misc.buildFull
            [ "aarch64-linux" ];

        # Control connected monitors' settings
        kernelModules = [ "i2c-dev" "ddcci" ];
        extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    };

    environment.systemPackages = let p = pkgs; in [
        # DDC monitor control
        p.ddcutil

        # Mouse config GUI
        p.piper

        # Smart cards, Yubikey
        p.opensc p.pcsctools p.yubikey-manager p.yubikey-manager-qt

        # Power management
        config.boot.kernelPackages.cpupower
    ];

    users = {
        users.anna.extraGroups = [
            # Allow i2c access for monitor control
            "i2c"
            
            # Allow ADB access to Android devices
            "adbusers"
        ];

        # Create groups
        groups.i2c = {};
        groups.adbusers = {};
    };

    # Android device debugging support
    programs.adb.enable = true;

    services = {
        # Mouse configuration
        ratbagd.enable = true;

        # Allow access to Apple devices via USB
        usbmuxd.enable = true;

        # Allow smart card and Yubikey access
        pcscd.enable = true;

        # Update device firmware
        fwupd = {
            enable = true;
            extraRemotes = [ "lvfs-testing" ];
        };
    };

    # Misc
    hardware.bluetooth.enable = true;
}