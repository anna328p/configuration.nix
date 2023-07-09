{ config, lib, pkgs, ... }:

{
    boot = {
        # Emulate ARM systems for remote deployments
        binfmt.emulatedSystems = lib.optionals config.misc.buildFull
            [ "aarch64-linux" ];

        # TODO: build broken with kernel 6.3, 2023-04-28
        # Control connected monitors' settings
        # kernelModules = [ "i2c-dev" "ddcci" ];
        # extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
        kernelModules = [ "i2c-dev" ];
    };

    environment.systemPackages = with pkgs; [
        # DDC monitor control
        ddcutil

        # PostScript interpreter for printing
        ghostscript

        # Mouse config GUI
        piper

        # Smart cards, Yubikey
        opensc pcsctools yubikey-manager yubikey-manager-qt

        # Power management
        config.boot.kernelPackages.cpupower
    ];

    # Mouse configuration
    services.ratbagd.enable = true;

    users.users.anna.extraGroups = [
        # Allow printing/scanning
        "lp" "scanner"

        # Allow i2c access for monitor control
        "i2c"
        
        # Allow ADB access to Android devices
        "adbusers"
    ];

    # Create groups
    users.groups.i2c = {};
    users.groups.adbusers = {};

    # CUPS
    # can't be configured more declaratively :(
    services.printing = {
        enable = true;
        drivers = with pkgs; [
            gutenprint gutenprintBin
            brlaser
            hll2390dw-cups
        ];
    };

    # Scanning
    hardware.sane = {
        enable = true;
        extraBackends = with pkgs; [ sane-airscan ];

        brscan5 = {
            enable = true;
            
            netDevices = {
                livingroom = {
                    model = "HL-L2390DW";
                    ip = "10.0.0.4";
                };
            };
        };
    };

    # Android device debugging support
    programs.adb.enable = true;

    # Allow access to Apple devices via USB
    services.usbmuxd.enable = true;

    # Allow smart card and Yubikey access
    services.pcscd.enable = true;

    # Update device firmware
    services.fwupd = {
        enable = true;
        extraRemotes = [ "lvfs-testing" ];
    };

    # Misc
    hardware.bluetooth.enable = true;
}
