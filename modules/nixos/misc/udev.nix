{ config, local-lib, lib, L, ... }:


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
        };
    };

    config = let
        cfg = config.misc;

        inherit (builtins) readFile concatLists;
        inherit (L) pipe' concatLines concatMapLines;
        inherit (lib) mkIf cartesianProduct;

    in {
        services.udev = mkIf cfg.udev.enable {
            extraRules = let
                uaccessRule = { vid, pid }:
                    ''SUBSYSTEMS=="usb", ATTRS{idVendor}=="${vid}", '' +
                    ''ATTRS{idProduct}=="${pid}", TAG+="uaccess"'';

                uaccessRules = pipe' [
                    (map cartesianProduct)
                    concatLists
                    (map uaccessRule)
                    concatLines
                ];

            in concatLines [
                (uaccessRules cfg.udev.usb.uaccessDevices)
                (concatMapLines readFile cfg.udev.extraRuleFiles)
                (concatLines cfg.udev.extraRules)
            ];
        };
    };
}