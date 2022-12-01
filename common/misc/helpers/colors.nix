{ lib, ... }:

rec {
	prefixHash = lib.mapAttrs (_: v: "#${v}");

	genDecls = template: defs: builtins.concatStringsSep "\n"
		(lib.mapAttrsToList template defs);

	genVarDecls = genDecls (k: v: "--${k}: ${v} !important;");

	byKind = kind: light: dark: { inherit light dark; }.${kind};
}
