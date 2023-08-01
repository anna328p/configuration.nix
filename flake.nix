{
    description = "NixOS system configurations";

    inputs = {
        # nixpkgs

        nixpkgs.url = flake:nixpkgs/nixos-unstable-small;
        nixpkgs-master.url = flake:nixpkgs/master;

        # libraries

        flake-utils.url = flake:flake-utils;

        flake-compat.url = github:edolstra/flake-compat;
        flake-compat.flake = false;

        flake-parts.url = github:hercules-ci/flake-parts;
        flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

        parsec.url = github:milahu/nix-parsec;

        # modules

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
        snm.inputs.nixpkgs-23_05.follows = "nixpkgs";
        snm.inputs.flake-compat.follows = "flake-compat";

        # packages

        neovim.url = github:neovim/neovim?dir=contrib;
        neovim.inputs.nixpkgs.follows = "nixpkgs";
        neovim.inputs.flake-utils.follows = "flake-utils";

        #nil.url = github:oxalica/nil;
        nil.url = github:jordanisaacs/nil;
        nil.inputs.flake-utils.follows = "flake-utils";

        transgui.url = github:transmission-remote-gui/transgui;
        transgui.flake = false;

        keydb.url = "https://github.com/anna328p/mirror/releases/latest/download/keydb_eng.zip";
        keydb.flake = false;

        vim-slim.url = github:slim-template/vim-slim;
        vim-slim.flake = false;

        rainbow-delimiters-nvim.url = gitlab:hiphish/rainbow-delimiters.nvim;
        rainbow-delimiters-nvim.flake = false;

        nvim-treesitter.url = github:nvim-treesitter/nvim-treesitter;
        nvim-treesitter.flake = false;

        nvim-cmp.url = github:PlankCipher/nvim-cmp/patch-1;
        nvim-cmp.flake = false;
    };

    nixConfig = {
        allow-import-from-derivation = "true";
    };

    outputs = { self
        , nixpkgs
        , nil
        , ...
    }@flakes: let
        localPkgs = import ./pkgs flakes;

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
            localPkgs.overlays.default
            nil.overlays.default
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

        eachExposedSystem = with nixpkgs.lib;
            genAttrs systems.flakeExposed;

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

        packages = eachExposedSystem (system:
            let pkgs = nixpkgs.legacyPackages.${system};
                in localPkgs.mkPackageSet pkgs
        );
    };
}