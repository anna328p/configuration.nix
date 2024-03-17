{ config, lib, pkgs, ... }:

{
    # flatpak
    services.flatpak.enable = true;

    # gpg agent
    programs = {
        gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
        };

        less.lessopen = "|${pkgs.lesspipe}/bin/lesspipe.sh %s"; # default

        nix-index = {
            enable = true;
            enableZshIntegration = true;
        };

        git.package = pkgs.gitFull;
    };
}