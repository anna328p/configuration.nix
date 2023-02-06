{ lib, ... }:

{
	imports = [
		./udev.nix
	];

	options.misc = with lib; {
		uuid = mkOption {
			type = types.str;
			description = "System-specific UUID";
		};
	};
}
