{ lib, ... }:

with lib; {
	exports = self: { inherit (self)
		mkGenericOption;
	};

	mkGenericOption = defaults: type: description: args:
		mkOption ({ inherit type description; } // defaults // args);
}
