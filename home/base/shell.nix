{ config, pkgs, ... }:

{
    home.shellAliases = {
        ls = "eza --hyperlink -F";
        ll = "ls -l --smart-group";

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
            unsetopt INTERACTIVE_COMMENTS

            for i in util escesc autopushd; do
                source ${files/zsh/snippets}/$i.zsh
            done

            export ZLE_RPROMPT_INDENT=0

            source ~/.config/zsh/.p10k.zsh

            unalias ll
        '';

        prezto = {
            enable = true;

            pmodules = [
                "environment"
                "helper"
                "utility"
                "editor"
                "history"
                "directory"
                "spectrum"
                "completion"
                "history-substring-search"
            ];

            editor.dotExpansion = true;
            utility.safeOps = false;
            terminal.autoTitle = true;
        };
    };

    programs.dircolors = {
        enable = true;
        enableZshIntegration = true;

        extraConfig = (builtins.readFile files/dircolors);
    };
}