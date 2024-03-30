{ config, local-lib, lib, L, ... }:


{
    options.misc.udev = let
        inherit (lib) mkOption mkEnableOption;
        inherit (lib.types) either listOf str submodule;

        usbId = local-lib.hexStringN 4;
        usbIds = either usbId (listOf usbId);

        mkIdOpt = rest: mkOption ({ type = usbIds; } // rest);

        usbDevSpec = submodule {
            options = {
                vid = mkIdOpt { };
                pid = mkIdOpt { };
            };
        };
    in {
        enable = mkEnableOption "simplified udev configuration";

        extraRuleFiles = mkOption {
            description = "List of files containing udev rules to import";
            type = listOf str;
        };

        extraRules = mkOption {
            description = "List of strings containing udev rules";
            type = listOf str;
        };

        usb = {
            uaccessDevices = mkOption {
                description = "List of USB device IDs to mark with the uaccess flag";
                type = listOf usbDevSpec;
            };
        };
    };

    config = let
        cfg = config.misc;

        inherit (builtins) mapAttrs concatMap readFile;
        inherit (L) o pipe' concatLines concatMapLines;
        inherit (lib) mkIf cartesianProductOfSets toList;

    in {
        services.udev = mkIf cfg.udev.enable {
            extraRules = let
                denormalize = o cartesianProductOfSets (mapAttrs (_: toList));

                uaccessRule = { vid, pid }:
                    ''SUBSYSTEMS=="usb", ATTRS{idVendor}=="${vid}", '' +
                    ''ATTRS{idProduct}=="${pid}", TAG+="uaccess"'';

                uaccessRules = pipe' [
                    (concatMap denormalize)
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