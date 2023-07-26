{
    description = "Overlays and packages for NixOS system configuration";

    inputs = {
        nixpkgs.url = flake:nixpkgs;
        flake-utils.url = flake:flake-utils;

        neovim-nightly-overlay.url =
            github:nix-community/neovim-nightly-overlay;
        neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

        nixd.url = github:nix-community/nixd;

        # Transmission
        
        transmission = {
            type = "git";
            url = "https://github.com/transmission/transmission";
            ref = "refs/tags/4.0.2";
            submodules = true;
            flake = false;
        };

        dht.url = github:transmission/dht/post-0.27-transmission;
        dht.flake = false;

        libutp.url = github:transmission/libutp/post-3.4-transmission;
        libutp.flake = false;

        transgui.url = github:transmission-remote-gui/transgui;
        transgui.flake = false;

        # Misc

        keydb.url =
            "https://github.com/anna328p/mirror/releases/latest/download/keydb_eng.zip";
        keydb.flake = false;

        protoplug.url = github:pac-dev/protoplug;
        protoplug.flake = false;

        vim-slim.url = github:slim-template/vim-slim;
        vim-slim.flake = false;

        rainbow-delimiters-nvim.url = gitlab:hiphish/rainbow-delimiters.nvim;
        rainbow-delimiters-nvim.flake = false;

        nvim-treesitter.url = github:nvim-treesitter/nvim-treesitter;
        nvim-treesitter.flake = false;

        nvim-cmp.url = github:PlankCipher/nvim-cmp/patch-1;
        nvim-cmp.flake = false;
    };

    outputs = { self
        , nixpkgs
        , flake-utils
        , ...
    }@flakes: let

        mkFlakeVer = flake: prefix: let
            shortRev = builtins.substring 0 7 flake.rev;
        in
            prefix + "-rev-" + shortRev;


        localOverlay = import ./overlays {
            inherit (nixpkgs) lib;
            inherit flakes mkFlakeVer;
        };
    in {
        overlays.default = localOverlay;

    } // flake-utils.lib.eachDefaultSystem (system: let
        pkgs = nixpkgs.legacyPackages.${system};
    in {
        packages = import ./all-packages.nix {
            inherit (pkgs) callPackage;
            inherit flakes mkFlakeVer;
        };
    });
}