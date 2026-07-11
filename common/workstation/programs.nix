{ config, ... }:

{
    # flatpak
    services.flatpak.enable = true;

    programs = {
        nix-index = {
            enable = true;
            enableZshIntegration = true;
        };

        appimage = {
            enable = config.misc.buildFull;
            binfmt = config.misc.buildFull;
        };

        nix-ld.enable = true;
    };
}