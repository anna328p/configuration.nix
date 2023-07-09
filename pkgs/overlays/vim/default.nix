{ flakes, ... }:

final: prev: let
    buildPlugin = final.vimUtils.buildVimPluginFrom2Nix;
in {
    vim-slim = buildPlugin {
        name = "vim-slim";
        src = flakes.vim-slim;
    };

    rainbow-delimiters-nvim = buildPlugin {
        name = "rainbow-delimiters-nvim";
        src = flakes.rainbow-delimiters-nvim;
    };
}