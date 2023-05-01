{
	description = "Overlays and packages for NixOS system configuration";

	inputs = {
		nixpkgs.url = flake:nixpkgs;
		flake-utils.url = flake:flake-utils;

		neovim.url = github:neovim/neovim?dir=contrib;
		neovim.inputs.flake-utils.follows = "flake-utils";

		# Transmission
		
		transmission = {
			type = "git";
			url = "https://github.com/transmission/transmission";
			ref = "refs/tags/4.0.2";
			submodules = true;
			flake = false;
		};

		dht.url = github:transmission/dht/post-0.27-transmission;
		dht.flake = false;

		libutp.url = github:transmission/libutp/post-3.4-transmission;
		libutp.flake = false;

		transgui.url = github:transmission-remote-gui/transgui;
		transgui.flake = false;

		# Misc

		keydb.url = "https://github.com/anna328p/mirror/releases/latest/download/keydb_eng.zip";
		keydb.flake = false;

		protoplug.url = github:pac-dev/protoplug;
		protoplug.flake = false;
	};

	outputs = { self
		, nixpkgs
		, flake-utils
		, ...
	}@flakes: let

		mkFlakeVer = flake: prefix: let
			shortRev = builtins.substring 0 7 flake.rev;
		in
			prefix + "-rev-" + shortRev;


		localOverlay = import ./overlays {
			inherit (nixpkgs) lib;
			inherit flakes mkFlakeVer;
		};
	in {
		overlays.default = localOverlay;

	} // flake-utils.lib.eachDefaultSystem (system: let
		pkgs = nixpkgs.legacyPackages.${system};
	in {
		packages = import ./all-packages.nix {
			inherit (pkgs) callPackage;
			inherit flakes mkFlakeVer;
		};
	});
}
