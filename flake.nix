{
    description = "NixOS system configurations";

    inputs = {
        # nixpkgs

        nixpkgs.url = flake:nixpkgs/nixos-unstable-small;
        nixpkgs-master.url = flake:nixpkgs/master;

        nixpkgs-ufr2.url = github:lluchs/nixpkgs/ufr2-gcc-rpath;

        nixpkgs-24_11.url = flake:nixpkgs/nixos-24.11;
        
        nixpkgs-linux610.url = flake:nixpkgs/dd50f99e26d3;

        # libraries

        nix-prelude.url = github:anna328p/nix-prelude;

        flake-utils.url = flake:flake-utils;

        flake-compat.url = github:edolstra/flake-compat;
        flake-compat.flake = false;

        flake-parts.url = flake:flake-parts;
        flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

        # home-manager

        home-manager.url = flake:home-manager;
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        # android

        nix-on-droid.url = github:nix-community/nix-on-droid;
        nix-on-droid.inputs = {
            nixpkgs.follows = "nixpkgs";
            nixpkgs-docs.follows = "nixpkgs";
            home-manager.follows = "home-manager";
        };

        # modules

        nixos-hardware.url = flake:nixos-hardware;
        impermanence.url = github:nix-community/impermanence;
        intransience.url = github:anna328p/intransience;

        nixos-generators.url = github:nix-community/nixos-generators;
        nixos-generators.inputs = {
            nixpkgs.follows = "nixpkgs";
            nixlib.follows = "nixpkgs";
        };

        nix-colors.url = github:misterio77/nix-colors;
        nix-colors.inputs.nixpkgs-lib.follows = "nixpkgs";

        musnix.url = github:musnix/musnix;
        musnix.inputs.nixpkgs.follows = "nixpkgs";

        qbot.url = github:arch-community/qbot;

        snm.url = gitlab:simple-nixos-mailserver/nixos-mailserver;
        snm.inputs = {
            nixpkgs.follows = "nixpkgs";
            nixpkgs-24_11.follows = "nixpkgs";
            flake-compat.follows = "flake-compat";
        };

        # packages

        nix.url = flake:nix;
        nix.inputs = {
            nixpkgs.follows = "nixpkgs";
            flake-compat.follows = "flake-compat";
            flake-parts.follows = "flake-parts";
        };

        neovim-nightly-overlay.url = github:nix-community/neovim-nightly-overlay;
        neovim-nightly-overlay.inputs = {
            nixpkgs.follows = "nixpkgs";
            flake-parts.follows = "flake-parts";
            flake-compat.follows = "flake-compat";
        };

        nil.url = github:oxalica/nil;
        nil.inputs.flake-utils.follows = "flake-utils";

        ghostty.url = github:ghostty-org/ghostty/tip;
        ghostty.inputs = {
            flake-compat.follows = "flake-compat";
            nixpkgs-stable.follows = "nixpkgs";
            nixpkgs-unstable.follows = "nixpkgs";
        };

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

        copilot-lualine.url = github:AndreM222/copilot-lualine;
        copilot-lualine.flake = false;
        
        # TODO remove once nvimdev/guard.nvim#160 merged
        guard-nvim.url = github:anna328p/guard.nvim;
        guard-nvim.flake = false;

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
        , nixos-generators
        , ...
    }@flakes: let
        localPkgs = import ./pkgs { inherit flakes; };

        inherit (import ./local-modules.nix) modulePaths;

        moduleSets = import ./module-sets.nix;

        inherit (import ./generators.nix flakes)
            specialArgs mkNixosSystem mkAndroidEnv;

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

        nixosConfigurations = mapAttrValues mkNixosSystem moduleSets.nixos;
        nixOnDroidConfigurations = mapAttrValues mkAndroidEnv moduleSets.android;

        overlays = {
            inherit (localPkgs.overlays) default;
        };

        packages = eachExposedSystem (system: let
            pkgs = import nixpkgs {
                inherit system;
                overlays = [ self.overlays.default ];
            };
        in
            (localPkgs.mkPackageSet pkgs)
            // {
                iso-x86_64 = import ./images/iso-x86_64
                    { inherit pkgs flakes specialArgs; };
            }
        );
    };
}