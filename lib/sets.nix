{ lib, L, ... }:

with lib; with L; rec {
	exports = self: { inherit (self)
		optionalAttr optionalsAttr

		mergeSets mergeSetsRec
		flattenSetSep
		mapAttrValues;
	};
	
	# optionalAttr : Str -> Set a -> [a]
	optionalAttr = attr: set:
		if set ? ${attr}
			then [ set.${attr} ]
			else [];

	# optionalsAttr : Str -> Set a -> (a | List)
	optionalsAttr = attr: set: set.${attr} or [];

	
	# mergeSets : [Set Any] -> Set Any
	mergeSets = foldl' (l: r: l // r) {};

	# mergeSetsRec : [Set Any] -> Set Any
	mergeSetsRec = foldl' recursiveUpdate {};

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

		in zipAttrsWith (_: mergeSets) (map (optionalValues a b) (diffNames a b));
	
	# flattenSetSep =
	#     sig Str _- Set Any _- Set (Except Set) __

	# flattenSetSep : Str -> Set Any -> Set (Except Set)
	flattenSetSep = sep: let
		isNameValuePair = val:
			isAttrs val && (attrNames val) == [ "name" "value" ];

		mkPair = path: nameValuePair (concatStringsSep sep path);
	in
		pipe' [
			(mapAttrsRecursive mkPair)
			(collect isNameValuePair)
			(listToAttrs)
		];
	
	# mapAttrValues =
	#     sig forall (a: b: (Fn a _- b) _- Set a _- Set b)

	# mapAttrValues : (a -> b) -> Set a -> Set b
	mapAttrValues = o mapAttrs const;
}
