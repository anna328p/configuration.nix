{ config, lib, L, ... }:

let
    scheme = config.colorScheme;
    colorsPrefixed = lib.mapAttrs (_: v: "#${v}") scheme.palette;
in {
    home.shellAliases = let
        t = " --show-trace";
        k = " --keep-going";
        f = " --fast";
    in rec {
        open = "xdg-open";

        nbs = "time nixos-rebuild switch --use-remote-sudo"
            + " --flake 'path:/etc/nixos'";

        nbst = nbs + t;
        nbsk = nbs + k;
        nbsf = nbs + f;

        nbstf = nbs + t + f;
        nbsft = nbs + f + t;
        nbskf = nbs + k + f;
        nbsfk = nbs + f + k;

        nsn = "nix search nixpkgs";
    };

    programs.zsh = {
        cdpath = [ "$HOME" ];

        enableVteIntegration = true;

        envExtra = ''
            export GPG_TTY=$(tty)
        '';

        dirHashes = {
            w = "$HOME/work";
            en = "/etc/nixos";
        };

        initContent = let
            base16Config = let
                fn = name: value: "zstyle :base16:colors ${name} '${value}'";
            in
                L.concatLines (L.mapSetEntries fn colorsPrefixed);
        in lib.mkBefore /* sh */ ''
            ${base16Config}

            zstyle :base16 available true
        '';

        prezto = {
            pmodules = [
                "tmux"
                "syntax-highlighting"
                "autosuggestions"
            ];

            tmux = {
                autoStartLocal = true;
                autoStartRemote = true;
            };

            syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" "line" "root" ];
            autosuggestions.color = "fg=blue";
        };
    };
    
    programs = {
        direnv = {
            enable = true;
            nix-direnv.enable = true;
            enableZshIntegration = true;
        };

        less.enable = true;
        lesspipe.enable = true;
    };
}