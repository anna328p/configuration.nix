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

	diffSets = a: b: let
		optionalValues = a: b: k: let
			get = set: key: if set ? ${key} then { ${key} = set.${key}; } else {};
		in
			{ a = get a n; b = get b n; };

		diffNames = a: b: let
			c = a // b;
			pred = k: (a ? ${k}) -> (b ? ${k}) -> (a.${k} != b.${k});
		in
			filter pred (attrNames c);

		foldSets = foldl' (l: r: l // r) {};

		in zipAttrsWith (_: foldSets) (map (optionalValues a b) (diffNames a b));
}
