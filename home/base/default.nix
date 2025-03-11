{ localModules, config, pkgs, lib, flakes, ... }:

{
    imports = [
        localModules.home.local.misc

        ./tmux.nix
        ./shell.nix
        ./git.nix
    ];

    home.stateVersion = "22.05";

    manual.manpages.enable = lib.mkDefault false;

    programs.man.enable = lib.mkDefault false;
}