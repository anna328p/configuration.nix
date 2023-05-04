{
	description = "NixOS system configurations";

	inputs = {
		nixpkgs.url = flake:nixpkgs/nixos-unstable-small;
		nixpkgs-master.url = flake:nixpkgs/master;

		flake-utils.url = flake:flake-utils;

		flake-compat.url = github:edolstra/flake-compat;
		flake-compat.flake = false;
		
		local-pkgs.url = "path:./pkgs";
		local-pkgs.inputs.nixpkgs.follows = "nixpkgs";
		local-pkgs.inputs.flake-utils.follows = "flake-utils";

		nur.url = flake:nur;
		nixos-hardware.url = flake:nixos-hardware;
		impermanence.url = github:nix-community/impermanence;

		nix-colors.url = github:misterio77/nix-colors;
		nix-colors.inputs.nixpkgs-lib.follows = "nixpkgs";

		home-manager.url = flake:home-manager;
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

		musnix.url = github:musnix/musnix;
		musnix.inputs.nixpkgs.follows = "nixpkgs";

		qbot.url = github:arch-community/qbot;
		qbot.inputs.flake-utils.follows = "flake-utils";

		snm.url = gitlab:simple-nixos-mailserver/nixos-mailserver;
		snm.inputs.utils.follows = "flake-utils";
		snm.inputs.nixpkgs.follows = "nixpkgs";
		snm.inputs.nixpkgs-22_11.follows = "nixpkgs";
		snm.inputs.flake-compat.follows = "flake-compat";
	};

	outputs = { self
		, nixpkgs
		, local-pkgs
		, nur
		, ...
	}@flakes: let
		nixosModules' = rec {
			default = common_module;

			common_module = common/module;

			common_base = common/base;
			common_physical = common/physical;
			common_server = common/server;
			common_virtual = common/virtual;
			common_workstation = common/workstation;

			common_misc_amd = common/misc/amd;
			common_misc_small = common/misc/small;

			systems_hermes = systems/hermes;
			systems_theseus = systems/theseus;

			systems_leonardo = systems/leonardo;
			systems_neo = systems/neo;
			systems_heracles = systems/heracles;
			systems_iris = systems/iris;
		};

		homeManagerModules' = rec {
			default = module;

			module = home/module;
			base = home/base;
			workstation = home/workstation;
		};

		localModules = nixosModules' // { home = homeManagerModules'; };

		flakeLib = import ./lib { inherit flakes; };

		overlays = [
			local-pkgs.overlays.default
			nur.overlay
		];

		mkNixosSystem = modules: nixpkgs.lib.nixosSystem {
			inherit modules;

			specialArgs = {
				inherit flakes overlays localModules;
				L = flakeLib;
			};
		};

		importMods = builtins.mapAttrs (_: import);
		mkSystems = builtins.mapAttrs (_: mkNixosSystem);

	in {
		lib = flakeLib;

		inputs = flakes;

		nixosModules = importMods nixosModules';
		homeManagerModules = importMods homeManagerModules';

		nixosConfigurations = let
			moduleSets = with localModules; rec {
				hermes = [ systems_hermes ];
				hermes-small = hermes ++ [ common_misc_small ];

				theseus = [ systems_theseus ];
				theseus-small = theseus ++ [ common_misc_small ];

				heracles = [ systems_heracles ];
				leonardo = [ systems_leonardo ];
				neo = [ systems_neo ];
				iris = [ systems_iris ];
			};

		in mkSystems moduleSets;
	};
}
