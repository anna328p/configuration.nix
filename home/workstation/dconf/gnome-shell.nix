{ lib, ... }:

{
    dconf.settings = let
        inherit (lib.hm.gvariant)
            mkArray
            type
            mkUint32
            ;
    in {
        "org/gnome/shell" = {
            welcome-dialog-last-shown-version = "99.0.0";

            enabled-extensions = mkArray type.string [
                "appindicatorsupport@rgcjonas.gmail.com"
                "gsconnect@andyholmes.github.io"
                "display-brightness-ddcutil@themightydeity.github.com"
                "user-theme@gnome-shell-extensions.gcampax.github.com"
                "blur-my-shell@aunetx"
                "transmission-daemon-ng@glerro.pm.me"
                "batterytime@typeof.pw"
            ];
        };

        "org/gnome/shell/weather" = {
            automatic-location = true;
        };

        "org/gnome/desktop/wm/preferences" = {
            focus-mode = "sloppy";
            resize-with-right-button = true;
        };

        "org/gnome/mutter" = {
            dynamic-workspaces = true;
        };

        "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = true;
        };

        "org/gnome/desktop/session" = {
            idle-delay = mkUint32 600;
        };

        "org/gnome/settings-daemon/plugins/power" = {
            idle-dim = false;

            sleep-inactive-battery-type = "suspend";
            sleep-inactive-battery-timeout = 1800;

            sleep-inactive-ac-type = "nothing";
        };

        "org/gnome/tweaks".show-extensions-notice = false;
    };
}