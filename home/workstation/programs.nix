{ systemConfig, ... }:

{
    services = {
        fluidsynth.enable = systemConfig.misc.buildFull;

        gpg-agent = {
            enable = true;
            enableSshSupport = true;
        };
    };

    programs = {
        obs-studio.enable = systemConfig.misc.buildFull;
    };
}