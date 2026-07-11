{ lib, pkgs, ... }:

{
    programs = {
        zsh = {
            enable = true;
            interactiveShellInit = "bindkey -e";
            vteIntegration = true;
            enableCompletion = true;
        };

        command-not-found.enable = false;

        less.lessopen = lib.mkDefault null;
    };

    users.defaultUserShell = pkgs.zsh;
}