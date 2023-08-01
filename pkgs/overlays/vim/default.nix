{ flakes, ... }:

final: prev: let
    nvim-pkgs = flakes.neovim.packages.${final.system};


    buildPlugin = final.vimUtils.buildVimPluginFrom2Nix;

    buildPluginFrom = sources: name:
        buildPlugin {
            inherit name;
            src = sources.${name};
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
    in
        pkg.overrideAttrs (_: overrides);

in {
    neovim-unwrapped = nvim-pkgs.neovim;

    vimPlugins = prev.vimPlugins.extend
        (vfinal: vprev: {
            inherit nvim-treesitter;
        } // buildPluginsFrom flakes [
            "vim-slim"
            "rainbow-delimiters-nvim"
            "nvim-cmp"
        ]);
}