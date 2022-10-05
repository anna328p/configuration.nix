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
		localOverlay = import overlays/local.nix;

		overlays = [ wayland.overlay nur.overlay localOverlay ];

		mkDerived = base: modules: extraModules: base (modules ++ extraModules);
		mkSystem = base: modules: mkDerived base modules [];

		toSystem = system: x: x."${system}";

		baseSystem = system: extraModules: nixpkgs.lib.nixosSystem rec {
			inherit system;

			pkgs = import nixpkgs {
				inherit system overlays;
				config.allowUnfree = true;
			};

			specialArgs = {
				inherit flakes;

				tcs = toSystem system;

				pkgsMaster = import nixpkgs-master {
					inherit system overlays;
					config.allowUnfree = true;
				};
			};

			modules = [ ./configuration.nix ] ++ extraModules;
		};

		basePhysical = mkDerived (baseSystem "x86_64-linux") [
			common/physical.nix
		];

		baseDesktop = mkDerived basePhysical [
			common/desktop.nix
			home-manager.nixosModule
		];

	in {
		nixosConfigurations = {
			hermes = mkSystem baseDesktop [
				systems/hermes

				impermanence.nixosModule
				nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
			];

			theseus = mkSystem baseDesktop [
				systems/theseus

				nixos-hardware.nixosModules.common-cpu-amd
				nixos-hardware.nixosModules.common-gpu-nvidia
				nixos-hardware.nixosModules.common-pc-ssd
			];
		};
	};
}
