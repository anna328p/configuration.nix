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
        nixosModulePaths = rec {
            default = common.module;

            common = {
                module = common/module;

                base = common/base;
                physical = common/physical;
                server = common/server;
                virtual = common/virtual;
                workstation = common/workstation;

                misc.amd = common/misc/amd;
                misc.ftp = common/misc/ftp.nix;
                misc.small = common/misc/small;
            };

            systems = {
                hermes = systems/hermes;
                theseus = systems/theseus;

                leonardo = systems/leonardo;
                angelia = systems/angelia;
                heracles = systems/heracles;
                iris = systems/iris;
            };
        };

        homeModulePaths = rec {
            default = module;

            module = home/module;
            base = home/base;
            workstation = home/workstation;
        };

        localModules = nixosModulePaths // { home = homeModulePaths; };

        overlays = [
            local-pkgs.overlays.default
            nur.overlay
        ];

        mkNixosSystem = modules: nixpkgs.lib.nixosSystem {
            inherit modules;

            specialArgs = {
                inherit flakes overlays localModules;
                L = self.lib;
            };
        };

        importMods = with self.lib;
            o (mapAttrValues import) (flattenSetSep "-");

        mkSystems = with self.lib;
            mapAttrValues mkNixosSystem;

    in {
        lib = import ./lib { inherit flakes; };

        inputs = flakes;

        nixosModules = importMods nixosModulePaths;
        homeManagerModules = importMods homeModulePaths;

        nixosConfigurations = let
            moduleSets = with localModules; rec {
                hermes = [ systems.hermes ];
                hermes-small = hermes ++ [ common.misc.small ];

                theseus = [ systems.theseus ];
                theseus-small = theseus ++ [ common.misc.small ];

                heracles = [ systems.heracles ];
                leonardo = [ systems.leonardo ];
                angelia = [ systems.angelia ];
                iris = [ systems.iris ];
            };

        in mkSystems moduleSets;
    };
}