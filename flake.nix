{
	description = "NixOS system configuration";

	inputs = {
		nixpkgs.url = github:nixos/nixpkgs/nixos-unstable-small;
		nixpkgs-master.url = github:nixos/nixpkgs/master;

		flake-utils.url = github:numtide/flake-utils;

		nur.url = github:nix-community/NUR;
		nixos-hardware.url = github:nixos/nixos-hardware;
		impermanence.url = github:nix-community/impermanence;

		nix-colors.url = github:misterio77/nix-colors;

		home-manager = {
			url = github:nix-community/home-manager;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		wayland = {
			url = github:nix-community/nixpkgs-wayland;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		neovim = {
			url = github:neovim/neovim?dir=contrib;
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};

		musnix = {
			url = github:musnix/musnix;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		keydb = {
			url = "http://fvonline-db.bplaced.net/export/keydb_eng.zip";
			flake = false;
		};
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
		, ...
	}@flakes: let
		# Library

		mkDerived = base: modules: (extra: base (modules ++ extra));

		mkFinal = base: mkDerived base [];

		mkConfig = sys: base: mods: (mkFinal base mods) sys;

		forSystem' = system: x: x."${system}";

		# Infrastructure

		baseConfig = extraModules: system: let
			forSystem = forSystem' system;

			overlays = let
				local = import ./overlays { inherit (nixpkgs) lib; };
			in [
				wayland.overlay
				nur.overlay
				local.overlay
			];

			mkNixpkgs = flake: import flake {
				inherit system overlays;
				config.allowUnfree = true;
			};
		in nixpkgs.lib.nixosSystem {
			inherit system;

			pkgs = mkNixpkgs nixpkgs;

			specialArgs = {
				inherit flakes forSystem;
				pkgsMaster = mkNixpkgs nixpkgs-master;
			};

			modules = [ common/base ] ++ extraModules;
		};

		basePhysical = mkDerived baseConfig [
			common/physical
		];

		baseWorkstation = mkDerived basePhysical [
			common/workstation
			home-manager.nixosModule
		];

	in {
		nixosConfigurations = {
			hermes = mkConfig "x86_64-linux" baseWorkstation [
				systems/hermes

				common/amd.nix

				impermanence.nixosModule
				nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
				nixos-hardware.nixosModules.common-cpu-amd-pstate
			];

			theseus = mkConfig "x86_64-linux" baseWorkstation [
				systems/theseus

				common/amd.nix

				nixos-hardware.nixosModules.common-cpu-amd
				nixos-hardware.nixosModules.common-gpu-amd
				nixos-hardware.nixosModules.common-pc-ssd
			];
		};
	};
}
