{ lib, L, ... }:

with lib; with L; rec {
	exports = self: { inherit (self)
		optionalAttr' optionalsAttr'
		optionalAttr optionalsAttr;
	};

	genericOptionalAttr = fn: name: set: fn': let
		val = getAttr name set;
	in
		if (isAttrs set) && (hasAttr name set) && !(isNull val)
			then (o fn fn') val
			else [];
	
	optionalsAttr' = genericOptionalAttr id;
	optionalAttr' = genericOptionalAttr singleton;

	toId = f: a: b: f a b id;

	optionalsAttr = toId optionalsAttr';
	optionalAttr = toId optionalAttr';
}
