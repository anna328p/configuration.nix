{
	description = "NixOS system configurations";

	inputs = {
		nixpkgs.url = github:nixos/nixpkgs/nixos-unstable-small;
		nixpkgs-master.url = github:nixos/nixpkgs/master;

		flake-utils.url = github:numtide/flake-utils;

		flake-parts.url = github:hercules-ci/flake-parts;
		flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

		flake-compat.url = github:edolstra/flake-compat;
		flake-compat.flake = false;
		
		lib-aggregate.url = github:nix-community/lib-aggregate;
		lib-aggregate.inputs.flake-utils.follows = "flake-utils";
		lib-aggregate.inputs.nixpkgs-lib.follows = "nixpkgs";

		nur.url = github:nix-community/NUR;
		nixos-hardware.url = github:nixos/nixos-hardware;
		impermanence.url = github:nix-community/impermanence;

		nix-colors.url = github:misterio77/nix-colors;
		nix-colors.inputs.nixpkgs-lib.follows = "nixpkgs";

		home-manager.url = github:nix-community/home-manager;
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.inputs.utils.follows = "flake-utils";

		nix-eval-jobs.url = github:nix-community/nix-eval-jobs;
		nix-eval-jobs.inputs.nixpkgs.follows = "nixpkgs";
		nix-eval-jobs.inputs.flake-parts.follows = "flake-parts";

		wayland.url = github:nix-community/nixpkgs-wayland;
		wayland.inputs.nixpkgs.follows = "nixpkgs";
		wayland.inputs.nix-eval-jobs.follows = "nix-eval-jobs";
		wayland.inputs.flake-compat.follows = "flake-compat";
		wayland.inputs.lib-aggregate.follows = "lib-aggregate";

		neovim.url = github:neovim/neovim?dir=contrib;
		neovim.inputs.flake-utils.follows = "flake-utils";

		musnix.url = github:musnix/musnix;
		musnix.inputs.nixpkgs.follows = "nixpkgs";

		qbot.url = github:arch-community/qbot;
		qbot.inputs.flake-utils.follows = "flake-utils";

		snm.url = gitlab:simple-nixos-mailserver/nixos-mailserver;
		snm.inputs.utils.follows = "flake-utils";
		snm.inputs.nixpkgs.follows = "nixpkgs";
		snm.inputs.nixpkgs-22_11.follows = "nixpkgs";
		snm.inputs.flake-compat.follows = "flake-compat";

		keydb.url = "https://github.com/anna328p/mirror/releases/latest/download/keydb_eng.zip";
		keydb.flake = false;

		usbmuxd.url = github:libimobiledevice/usbmuxd;
		usbmuxd.flake = false;

		idevicerestore.url = github:libimobiledevice/idevicerestore;
		idevicerestore.flake = false;
	};

	outputs = { self
		, nixpkgs
		, nixpkgs-master
		, flake-utils
		, nur
		, nixos-hardware
		, impermanence
		, home-manager
		, wayland
		, neovim
		, musnix
		, qbot
		, snm
		, ...
	}@flakes: let
		mkConfigBuilder = callback: rec {
			inherit callback;

			modules = [ ];
			realise = callback modules;

			__functor = self: extraModules: let
				modules = self.modules ++ extraModules;
				realise = self.callback modules;
			in
				self // { inherit modules realise; };
		};

		flakeLib = import ./lib { inherit flakes; };

		localOverlay = import ./overlays {
			inherit (nixpkgs) lib;
			inherit flakes;
		};

		overlays = [
			localOverlay
			wayland.overlay
			nur.overlay
			qbot.overlay
		];

		mkNixosSystem = modules: system: let
			importPkgs = path: import path {
				inherit system overlays;

				config.allowUnfree = true;
				config.allowBroken = true;
			};

			pkgs = importPkgs nixpkgs;
			pkgsMaster = importPkgs nixpkgs-master;

			L = flakeLib;
		in
			nixpkgs.lib.nixosSystem {
				inherit system pkgs modules;

				specialArgs = { inherit flakes pkgsMaster L; };
			};

		baseConfig = mkConfigBuilder mkNixosSystem [ common/base ];

		baseServer = baseConfig [ common/server ];
		virtualServer = baseServer [ common/virtual ];

		basePhysical = baseConfig [ common/physical ];
		baseWorkstation = basePhysical [ common/workstation ];

		amdWorkstation = baseWorkstation [
			nixos-hardware.nixosModules.common-cpu-amd
			nixos-hardware.nixosModules.common-gpu-amd
			common/misc/amd
		];

		noBuildFull = { ... }: { misc.buildFull = false; };

	in {
		lib = flakeLib;

		inputs = flakes;

		overlays = rec {
			local = localOverlay;
			default = local;
		};

		nixosConfigurations = let
			configs = rec {
				hermes = amdWorkstation [ systems/hermes ];
				hermes-small = hermes [ noBuildFull ];

				theseus = amdWorkstation [ systems/theseus ];
				theseus-small = theseus [ noBuildFull ];

				heracles = virtualServer [ systems/heracles ];
				leonardo = virtualServer [ systems/leonardo ];
				neo = virtualServer [ systems/neo ];
				iris = virtualServer [ systems/iris ];
			};

			systems = {
				default = "x86_64-linux";

				heracles = "aarch64-linux";
			};

			systemFor = name: with builtins;
				if hasAttr name systems
					then getAttr name systems
					else systems.default;

		in builtins.mapAttrs
			(name: config: config.realise (systemFor name))
			configs;
	};
}
