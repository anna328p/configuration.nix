{ pkgs, systemConfig, ... }:

{
    services = {
        fluidsynth = {
            enable = systemConfig.misc.buildFull;
            soundService = "pipewire-pulse";
        };

        gpg-agent = {
            enable = true;
            enableSshSupport = true;
            pinentry.package = pkgs.pinentry-gnome3;
        };
    };

    programs = {
        gpg.enable = true;
        obs-studio.enable = systemConfig.misc.buildFull;
    };

    xdg.autostart = {
        enable = true;

        entries = [
            "/run/current-system/sw/share/applications/org.keepassxc.KeePassXC.desktop"
        ];
    };
}