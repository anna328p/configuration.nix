{ config, lib, L, ... }:

with lib; let
	T = rec {
		inherit (types) either listOf str submodule;

		usbId = L.types.hexStringN 4;
		usbIds = either usbId (listOf usbId);

		mkIdOpt = rest: mkOption ({ type = usbIds; } // rest);

		usbDevSpec = submodule {
			options = {
				vid = mkIdOpt { };
				pid = mkIdOpt { };
			};
		};
	};

in {
	options.misc.udev = {
		extraRuleFiles = mkOption {
			description = "List of files containing udev rules to import";
			type = T.listOf T.str;
		};

		extraRules = mkOption {
			description = "List of strings containing udev rules";
			type = T.listOf T.str;
		};

		usb = {
			uaccessDevices = mkOption {
				description = "List of USB device IDs to mark with the uaccess flag";
				type = T.listOf T.usbDevSpec;
			};
		};
	};

	config = let
		cfg = config.misc;
	in {
		services.udev = {
			extraRules = with L; let
				denormalize = o cartesianProductOfSets (mapAttrs (_: toList));

				uaccessRule = { vid, pid }:
					''SUBSYSTEMS=="usb", ATTRS{idVendor}=="${vid}", '' +
					''ATTRS{idProduct}=="${pid}", TAG+="uaccess"'';

				uaccessRules = pipe' [
					(concatMap denormalize)
					(map uaccessRule)
					(concatLines)
				];

			in concatLines [
				(uaccessRules cfg.udev.usb.uaccessDevices)
				(concatMapLines readFile cfg.udev.extraRuleFiles)
				(concatLines cfg.udev.extraRules)
			];
		};
	};
}
