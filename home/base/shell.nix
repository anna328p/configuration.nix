{ config, pkgs, ... }:

{
    home.shellAliases = {
        ls = "eza";

        ":w" = "sync";
        ":q" = "exit";
        ":wq" = "sync; exit";
    };

    home.file.".config/zsh/.p10k.zsh".source = files/zsh/p10k.zsh;

    programs.zsh = {
        enable = true;
        dotDir = ".config/zsh";

        enableCompletion = true;

        sessionVariables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
        };

        envExtra = ''
            export DEFAULT_USER=$(whoami)
        '';

        history = {
            expireDuplicatesFirst = true;
            extended = true;
            path = "${config.xdg.dataHome}/zsh/zsh_history";
            save = 100000;
            size = 100000;
        };

        initExtraFirst = ''
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        '';

        initExtra = ''
            zmodload zsh/attr
            zmodload zsh/stat
            zmodload zsh/zpty
            
            autoload zmv
            autoload zargs
            
            setopt GLOB_DOTS
            for i in util escesc autopushd; do
                source ${files/zsh/snippets}/$i.zsh
            done
        '';

        prezto = {
            enable = true;

            pmodules = [
                "environment"
                "editor"
                "history"
                "directory"
                "spectrum"
                "helper"
                "utility"
                "completion"
                "history-substring-search"
            ];

            editor.dotExpansion = true;

            utility.safeOps = false;
        };
    };

    programs.dircolors = {
        enable = true;
        enableZshIntegration = true;

        extraConfig = (builtins.readFile files/dircolors);
    };
}