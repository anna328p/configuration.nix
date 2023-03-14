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
		# Library

		mkBaseConfig = callback: {
			modules = [ ];

			__functor = self: extraModules:
				self // { modules = self.modules ++ extraModules; };

			inherit callback;
		};

		realise = base: base.callback base.modules;

		mkConfig = system: base: modules: realise (base modules) system;

		flakeLib = import ./lib { inherit flakes; };

		# Infrastructure

		mkNixosSystem = modules: system: let
			forSystem = builtins.getAttr system;

			overlays = let
				inherit (forSystem nixpkgs.legacyPackages) callPackage;
				local = callPackage ./overlays { inherit flakes; };
			in [
				wayland.overlay
				nur.overlay
				qbot.overlay
				local.overlay
			];

			mkNixpkgs = flake: import flake {
				inherit system overlays;
				config.allowUnfree = true;
			};
		in nixpkgs.lib.nixosSystem rec {
			inherit system;

			pkgs = mkNixpkgs nixpkgs;

			specialArgs = {
				inherit flakes forSystem;
				pkgsMaster = mkNixpkgs nixpkgs-master;

				L = flakeLib;
			};

			inherit modules;
		};

		baseConfig = mkBaseConfig mkNixosSystem [
			home-manager.nixosModule
			common/base
		];

		baseServer = baseConfig [ common/server ];
		virtualServer = baseServer [ common/virtual ];

		basePhysical = baseConfig [ common/physical ];
		baseWorkstation = basePhysical [ common/workstation ];

	in {
		lib = flakeLib;

		inputs = flakes;

		nixosConfigurations = {
			hermes = mkConfig "x86_64-linux" baseWorkstation [
				systems/hermes

				common/misc/amd

				impermanence.nixosModule
				nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
				nixos-hardware.nixosModules.common-cpu-amd-pstate
			];

			theseus = mkConfig "x86_64-linux" baseWorkstation [
				systems/theseus

				common/misc/amd

				nixos-hardware.nixosModules.common-cpu-amd
				nixos-hardware.nixosModules.common-gpu-amd
				nixos-hardware.nixosModules.common-pc-ssd
			];

			heracles = mkConfig "aarch64-linux" virtualServer [
				systems/heracles

				qbot.nixosModules.default
			];

			leonardo = mkConfig "x86_64-linux" virtualServer [
				systems/leonardo
			];

			neo = mkConfig "x86_64-linux" virtualServer [
				systems/neo
			];

			iris = mkConfig "x86_64-linux" virtualServer [
				systems/iris

				snm.nixosModules.default
			];
		};
	};
}
