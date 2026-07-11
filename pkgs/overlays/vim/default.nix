{ flakes, ... }:

final: prev: let
    inherit (final.stdenv.hostPlatform) system;

    nvim-pkgs = flakes.neovim-nightly-overlay.packages.${system};

    unstableSmall = flakes.nixpkgs-unstable-small.legacyPackages.${system};

    buildPlugin = final.vimUtils.buildVimPlugin;

    buildPluginFrom = sources: name:
        buildPlugin {
            inherit name;
            src = sources.${name};
            doCheck = false;
        };

    buildPluginsFrom = sources: names:
        prev.lib.genAttrs names (buildPluginFrom sources);


    nvim-treesitter = let
        pkg = buildPluginFrom flakes "nvim-treesitter";

        src = flakes.nixpkgs
            + "/pkgs/applications/editors/vim"
            + "/plugins/nvim-treesitter/overrides.nix";

        set = { nvim-treesitter = pkg; };

        overrides = final.callPackage src { } set set;

        pkg' = pkg.overrideAttrs (_: overrides);
    in
        pkg'.overrideAttrs (oa: {
            postPatch = "";
        });

    nvimOverlay = vfinal: vprev: {
        inherit nvim-treesitter;

        # HACK
        neotest = vprev.neotest.overrideAttrs (old: {
            doCheck = false;
        });

        # TODO: remove when NixOS/nixpkgs#523577 makes it to unstable
        inherit (unstableSmall.vimPlugins) blink-pairs;

    } // buildPluginsFrom flakes [
        "vim-slim"
        "rainbow-delimiters-nvim"
        "copilot-lualine"
        "nvim-treesitter-textobjects"
    ];

in {
    neovim-unwrapped = nvim-pkgs.neovim;

    vimPlugins = prev.vimPlugins.extend nvimOverlay;
}