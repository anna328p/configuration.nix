{ config, pkgs, lib, flakes, ... }:

{
    imports = [
        ../module

        ./tmux.nix
        ./shell.nix
        ./git.nix
    ];

    home.stateVersion = "22.05";

    manual.manpages.enable = lib.mkDefault false;
}