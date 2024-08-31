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

        # home-manager

        home-manager.url = flake:home-manager;
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        # android

        nix-on-droid = {
            url = github:nix-community/nix-on-droid;
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.home-manager.follows = "home-manager";
        };

        # modules

        nixos-hardware.url = flake:nixos-hardware;
        impermanence.url = github:nix-community/impermanence;
        intransience.url = github:anna328p/intransience;

        nix-colors.url = github:misterio77/nix-colors;
        nix-colors.inputs.nixpkgs-lib.follows = "nixpkgs";

        musnix.url = github:musnix/musnix;
        musnix.inputs.nixpkgs.follows = "nixpkgs";

        qbot.url = github:arch-community/qbot;

        snm = {
            url = gitlab:simple-nixos-mailserver/nixos-mailserver;
            inputs = {
                nixpkgs.follows = "nixpkgs";
                nixpkgs-24_05.follows = "nixpkgs";
                flake-compat.follows = "flake-compat";
            };
        };

        # packages

        neovim-nightly-overlay = {
            url = github:nix-community/neovim-nightly-overlay;

            inputs = {
                nixpkgs.follows = "nixpkgs";
                flake-parts.follows = "flake-parts";
                flake-compat.follows = "flake-compat";
            };
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

        modemmanager-enz7360.url =
            gitlab:ShaneParslow/ModemManager/enz7360?host=gitlab.freedesktop.org;
        modemmanager-enz7360.flake = false;
    };

    nixConfig = {
        allow-import-from-derivation = "true";

        extra-substituters = ''
            https://nix-community.cachix.org
            https://anna328p.cachix.org
        '';

        extra-trusted-public-keys = ''
            nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
            anna328p.cachix.org-1:HcPUMrtQ7qT+bfx2fQ2HyJV5wCYQ2A3WwhxxrxDkvG0=
        '';
    };

    outputs = { self
        , nixpkgs
        , nil
        , nix-prelude
        , nix-on-droid
        , ...
    }@flakes: let
        localPkgs = import ./pkgs flakes;

        ##
        # Module paths

        modulePaths.nixos = rec {
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

        modulePaths.home = rec {
            default = local.misc;

            local = {
                misc = modules/home/misc;
            };

            module = home/module;
            base = home/base;
            workstation = home/workstation;
        };

        modulePaths.android = {
            devices = {
                aither = android/devices/aither;
            };
        };

        localModules = modulePaths.nixos // {
            inherit (modulePaths) home android;
        };

        ##
        # Generic config generation

        specialArgs = let
            L = nix-prelude.lib;

            local-lib = import ./lib {
                inherit (nixpkgs) lib;
                inherit L;
            };

            overlays = [
                self.overlays.default
                nil.overlays.default
            ];
        in
            { inherit flakes overlays localModules local-lib L; };

        mkNixosSystem = modules: nixpkgs.lib.nixosSystem {
            inherit modules specialArgs;
        };

        mkAndroidEnv = modules: let
            pkgs = import nixpkgs {
                system = "aarch64-linux";
                inherit (specialArgs) overlays;
            };
        in nix-on-droid.lib.nixOnDroidConfiguration {
            inherit modules pkgs;
            extraSpecialArgs = specialArgs;
        };

        ##
        # Flake stuff

        inherit (nix-prelude.lib) o mapAttrValues flattenSetSep;
        inherit (nixpkgs.lib) genAttrs systems;

        importMods = o (mapAttrValues import) (flattenSetSep "-");
        eachExposedSystem = genAttrs systems.flakeExposed;

    in {
        inputs = flakes;

        nixosModules = importMods modulePaths.nixos;
        homeManagerModules = importMods modulePaths.home;
        nixOnDroidModules = importMods modulePaths.android;

        nixosConfigurations = let
            inherit (localModules) systems common;

            moduleSets = rec {
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
            mapAttrValues mkNixosSystem moduleSets;

        nixOnDroidConfigurations = let
            inherit (localModules.android) devices;

            moduleSets = {
                aither = [ devices.aither ];
            };
        in
            mapAttrValues mkAndroidEnv moduleSets;

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