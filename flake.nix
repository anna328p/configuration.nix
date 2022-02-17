{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable-small;
    nixpkgs-master.url = github:nixos/nixpkgs/master;

    nur.url = github:nix-community/NUR;
    nixos-hardware.url = github:nixos/nixos-hardware;
    impermanence.url = github:nix-community/impermanence;

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
    };

    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self
    , flake-utils
    , nixpkgs
    , nixpkgs-master
    , home-manager
    , wayland
    , nur
    , neovim
    , nixos-hardware
    , impermanence
    , ...
  }@flakes: let
    localOverlay = import overlays/local.nix;

    overlays = [ wayland.overlay nur.overlay neovim.overlay localOverlay ];

    mkDerived = base: modules: extraModules: base (modules ++ extraModules);
    mkSystem = base: modules: mkDerived base modules [];

    baseSystem = system: extraModules: nixpkgs.lib.nixosSystem rec {
      inherit system;

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      specialArgs = {
		  inherit flakes;

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
        impermanence.nixosModules.impermanence
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
      ];

      theseus = mkSystem baseDesktop [
      	systems/theseus
      ];
    };
  };
}
