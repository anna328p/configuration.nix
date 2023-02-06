{ flakes }:

let
	inherit (flakes.nixpkgs) lib;

	flakeLib = lib.makeExtensible (self: let
		callLib = file: args:
			import file ({
				inherit lib using;
				L = self;
			} // args);

		importOneLib = name: path:
			{ ${name} = callLib path { }; };

		foldSets = lib.foldl lib.mergeAttrs { };

		importLibSet = libs:
			foldSets (lib.mapAttrsToList importOneLib libs);

		foldExports = imports: let
			callExports = _: lib: lib.exports lib;
		in
			imports // foldSets (lib.mapAttrsToList callExports imports);

		usingImportLibs = set:
			foldExports (importLibSet set);

		using = libs: rest: let
			imports = usingImportLibs libs;
		in
			imports // rest imports;

	in using {
		base = ./base.nix;

		strings-lists = ./strings-lists.nix;
		colors = ./colors.nix;
		_urlencode = ./urlencode.nix;
		base64 = ./base64.nix;
		misc = ./misc.nix;
		types = ./types.nix;
	} (_: {}));
in flakeLib
