{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable-small;
    nur.url = github:nix-community/NUR;

    nixos-hardware.url = github:nixos/nixos-hardware;

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
    , home-manager
    , wayland
    , nur
    , neovim
    , nixos-hardware
  }: let
    localOverlay = import ./overlay.nix;

    overlays = [ wayland.overlay nur.overlay neovim.overlay localOverlay ];

    baseSystem = extraModules: nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      modules = [
        ./configuration.nix
        home-manager.nixosModule

        ({ ... }: {
          home-manager = {
            users.anna = (import ./home.nix { inherit (pkgs) neovim; });
            useUserPackages = true;
            useGlobalPkgs = true;
          };

          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
        })
      ] ++ extraModules;
    };
  in {
    nixosConfigurations.hermes = baseSystem [
      nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
    ];
  };
}
