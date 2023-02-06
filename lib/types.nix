{ lib, L, ... }:

with lib; {
	exports = self: {};

	# hexString : OptionType
	hexString = types.strMatching "^[[:xdigit:]]*$";

	# hexStringN : Num -> OptionType
	hexStringN = len: let
		n = toString len;
	in
		types.strMatching "^[[:xdigit:]]{${n}}$";
}
