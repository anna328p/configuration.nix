{ config, local-lib, lib, L, pkgs, ... }:


{
    options.misc.udev = let
        inherit (lib) mkOption mkEnableOption;
        t = lib.types;

        usbId = local-lib.hexStringN 4;

        usbIds = t.coercedTo usbId (v: [ v ]) (t.listOf usbId);

        usbDevSpec = t.submodule {
            options = {
                vid = mkOption { type = usbIds; description = "Vendor ID";  };
                pid = mkOption { type = usbIds; description = "Product ID"; };
            };
        };
    in {
        enable = mkEnableOption "simplified udev configuration";

        extraRuleFiles = mkOption {
            description = "List of files containing udev rules to import";
            type = t.listOf t.str;
        };

        extraRules = mkOption {
            description = "List of strings containing udev rules";
            type = t.listOf t.str;
        };

        usb = {
            uaccessDevices = mkOption {
                description = "List of USB device IDs to mark with the uaccess flag";
                type = t.listOf usbDevSpec;
            };

            mtpNoProbe = mkOption {
                description = "List of USB devices for which to disable MTP probing";
                type = t.listOf usbDevSpec;
            };
        };
    };

    config = let
        cfg = config.misc;

        inherit (builtins) readFile concatLists;
        inherit (L) pipe' concatLines concatMapLines;
        inherit (lib) mkIf cartesianProduct;

        usbRules = let
            mkRules = mkRule: 
                pipe' [
                    (map cartesianProduct)
                    concatLists
                    (map mkRule)
                    concatLines
                ];

            mkUSBRule = rest:
                { vid, pid }:
                    ''SUBSYSTEMS=="usb"''
                    + '', ATTRS{idVendor}=="${vid}"''
                    + '', ATTRS{idProduct}=="${pid}"''
                    + '', ${rest}'';

            uaccessRule = mkUSBRule ''TAG+="uaccess"'';
            mtpNoProbeRule = mkUSBRule ''ENV{MTP_NO_PROBE}="1"'';

        in concatLines [
            (mkRules uaccessRule cfg.udev.usb.uaccessDevices)
            (mkRules mtpNoProbeRule cfg.udev.usb.mtpNoProbe)
            (concatMapLines readFile cfg.udev.extraRuleFiles)
            (concatLines cfg.udev.extraRules)
        ];

        usbRulesPkg = pkgs.writeTextFile {
            name = "udev-rules-usb";
            text = usbRules;
            destination = "/etc/udev/rules.d/65-usb.rules";
        };

    in {
        services.udev = mkIf cfg.udev.enable {
            packages = [ usbRulesPkg ];
        };
    };
}