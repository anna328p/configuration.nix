{ ... }:

{
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

        nbstf = nbst + f;
        nbsft = nbsf + t;
        nbskf = nbsk + f;
        nbsfk = nbsf + k;

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
    
    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableZshIntegration = true;
    };
}