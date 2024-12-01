{ pkgs, systemConfig, ... }:

{
    services = {
        fluidsynth.enable = systemConfig.misc.buildFull;

        gpg-agent = {
            enable = true;
            enableSshSupport = true;
            pinentryPackage = pkgs.pinentry-gnome3;
        };
    };

    programs = {
        gpg.enable = true;
        obs-studio.enable = systemConfig.misc.buildFull;
    };
}