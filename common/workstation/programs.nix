{ config, lib, pkgs, ... }:

{
    # flatpak
    services.flatpak.enable = true;

    programs = {
        nix-index = {
            enable = true;
            enableZshIntegration = true;
        };

        git.package = if config.misc.buildFull
            then pkgs.gitFull
            else pkgs.gitMinimal;

        appimage = {
            enable = config.misc.buildFull;
            binfmt = config.misc.buildFull;
        };
    };
}