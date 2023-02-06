{ lib, L, ... }:

with lib; with L; rec {
	exports = self: { inherit (self)
		prefixHash genDecls genVarDecls byKind;
	};

	prefixAttrs = pfx: mapAttrs (_: addStrings pfx);
	prefixHash = prefixAttrs "#";

	genDecls = oo concatLines mapAttrsToList;

	genVarDecls = genDecls (k: v: "--${k}: ${v} !important;");

	byKind = kind: light: dark: { inherit light dark; }.${kind};
}
