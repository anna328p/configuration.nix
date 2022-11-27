{ lib, ... }:

{
	options.misc = with lib; {
		uuid = mkOption {
			type = types.str;
			description = "System-specific UUID";
		};
	};
}
