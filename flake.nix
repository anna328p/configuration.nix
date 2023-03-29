{
	description = "NixOS system configurations";

	inputs = {
		nixpkgs.url = github:nixos/nixpkgs/nixos-unstable-small;
		nixpkgs-master.url = github:nixos/nixpkgs/master;

		flake-utils.url = github:numtide/flake-utils;

		flake-compat.url = github:edolstra/flake-compat;
		flake-compat.flake = false;
		
		nur.url = github:nix-community/NUR;
		nixos-hardware.url = github:nixos/nixos-hardware;
		impermanence.url = github:nix-community/impermanence;

		nix-colors.url = github:misterio77/nix-colors;
		nix-colors.inputs.nixpkgs-lib.follows = "nixpkgs";

		home-manager.url = github:nix-community/home-manager;
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.inputs.utils.follows = "flake-utils";

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
		, neovim
		, musnix
		, qbot
		, snm
		, ...
	}@flakes: let
		localModules = {
			common = {
				module = common/module;

				base = common/base;
				physical = common/physical;
				server = common/server;
				virtual = common/virtual;
				workstation = common/workstation;

				misc = {
					amd = common/misc/amd;
					small = common/misc/small;
				};

				home = {
					module = common/home/module;

					base = common/home/base;
					workstation = common/home/workstation;
				};
			};

			systems = {
				hermes = systems/hermes;
				theseus = systems/theseus;

				leonardo = systems/leonardo;
				neo = systems/neo;
				heracles = systems/heracles;
				iris = systems/iris;
			};
		};

		flakeLib = import ./lib { inherit flakes; };

		localOverlay = import ./overlays {
			inherit (nixpkgs) lib;
			inherit flakes;
		};

		overlays = [
			localOverlay
			nur.overlay
			qbot.overlay
		];

		mkNixosSystem = modules: nixpkgs.lib.nixosSystem {
			inherit modules;

			specialArgs = {
				inherit flakes overlays localModules;
				L = flakeLib;
			};
		};

	in {
		lib = flakeLib;

		inputs = flakes;

		overlays = rec {
			local = localOverlay;
			default = local;
		};

		nixosModules = localModules // {
			default = localModules.common.module;
		};

		nixosConfigurations = let
			moduleSets = with localModules; rec {
				hermes = [ systems.hermes ];
				hermes-small = hermes ++ [ common.misc.small ];

				theseus = [ systems.theseus ];
				theseus-small = theseus ++ [ common.misc.small ];

				heracles = [ systems.heracles ];
				leonardo = [ systems.leonardo ];
				neo = [ systems.neo ];
				iris = [ systems.iris ];
			};

		in builtins.mapAttrs (_: mkNixosSystem) moduleSets;
	};
}
