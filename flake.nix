{
    description = "NixOS system configurations";

    inputs = {
        # nixpkgs

        nixpkgs.url = flake:nixpkgs/nixos-unstable-small;
        nixpkgs-master.url = flake:nixpkgs/master;

        # libraries

        nix-prelude.url = github:anna328p/nix-prelude;

        flake-utils.url = flake:flake-utils;

        flake-compat.url = github:edolstra/flake-compat;
        flake-compat.flake = false;

        flake-parts.url = github:hercules-ci/flake-parts;
        flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

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

        snm = {
            url = gitlab:simple-nixos-mailserver/nixos-mailserver;
            inputs = {
                utils.follows = "flake-utils";
                nixpkgs.follows = "nixpkgs";
                flake-compat.follows = "flake-compat";
            };
        };

        # packages

        neovim = {
            url = github:neovim/neovim?dir=contrib;
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.flake-utils.follows = "flake-utils";
        };

        nil.url = github:oxalica/nil;
        nil.inputs.flake-utils.follows = "flake-utils";

        keydb = {
            url = "https://github.com/anna328p/mirror/releases/latest/download/keydb_eng.zip";
            type = "file";
            flake = false;
        };

        vim-slim.url = github:slim-template/vim-slim;
        vim-slim.flake = false;

        rainbow-delimiters-nvim.url = gitlab:hiphish/rainbow-delimiters.nvim;
        rainbow-delimiters-nvim.flake = false;

        nvim-treesitter.url = github:nvim-treesitter/nvim-treesitter;
        nvim-treesitter.flake = false;

        easyeffects-presets.url = github:digitalone1/easyeffects-presets;
        easyeffects-presets.flake = false;

        modemmanager-enz7360.url = gitlab:ShaneParslow/ModemManager/enz7360?host=gitlab.freedesktop.org;
        modemmanager-enz7360.flake = false;
    };

    nixConfig = {
        allow-import-from-derivation = "true";
    };

    outputs = { self
        , nixpkgs
        , nil
        , nix-prelude
        , ...
    }@flakes: let
        localPkgs = import ./pkgs flakes;

        nixosModulePaths = rec {
            default = local.misc;

            local = {
                misc = modules/nixos/misc;
            };

            common = {
                base = common/base;
                physical = common/physical;
                server = common/server;
                virtual = common/virtual;
                workstation = common/workstation;

                impermanent = common/impermanent;

                misc = {
                    amd = common/misc/amd;
                    ftp = common/misc/ftp;
                    small = common/misc/small;
                };
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
            default = local.misc;

            local = {
                misc = modules/home/misc;
            };

            module = home/module;
            base = home/base;
            workstation = home/workstation;
        };

        localModules = nixosModulePaths // { home = homeModulePaths; };


        mkNixosSystem = modules: let
            L = nix-prelude.lib;

            local-lib = import ./lib {
                inherit (nixpkgs) lib; inherit L;
            };
        in nixpkgs.lib.nixosSystem {
            inherit modules;

            specialArgs = let
                overlays = [
                    self.overlays.default
                    nil.overlays.default
                ];
            in {
                inherit flakes overlays localModules local-lib L;
            };
        };

        importMods = let
            inherit (nix-prelude.lib) o mapAttrValues flattenSetSep;
        in
            o (mapAttrValues import) (flattenSetSep "-");

        mkSystems = let
            inherit (nix-prelude.lib) mapAttrValues;
        in
            mapAttrValues mkNixosSystem;

        eachExposedSystem = let
            inherit (nixpkgs.lib) genAttrs systems;
        in
            genAttrs systems.flakeExposed;

    in {
        inputs = flakes;

        nixosModules = importMods nixosModulePaths;
        homeManagerModules = importMods homeModulePaths;

        nixosConfigurations = let
            moduleSets = let
                inherit (localModules) systems common;
            in rec {
                hermes = [ systems.hermes ];
                hermes-small = hermes ++ [ common.misc.small ];

                theseus = [ systems.theseus ];
                theseus-small = theseus ++ [ common.misc.small ];

                heracles = [ systems.heracles ];
                leonardo = [ systems.leonardo ];
                angelia = [ systems.angelia ];
                iris = [ systems.iris ];
            };
        in
            mkSystems moduleSets;

        overlays = {
            inherit (localPkgs.overlays) default;
        };

        packages = eachExposedSystem (system: let
            pkgs = import nixpkgs {
                inherit system;
                overlays = [ self.overlays.default ];
            };
        in
            localPkgs.mkPackageSet pkgs
        );
    };
}