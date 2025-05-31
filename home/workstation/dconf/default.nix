{ pkgs, lib, config, flakes, L, ... }:

{
    imports = [
        ./gsconnect.nix
    ];

    dconf.settings = let self = let
        inherit (lib.hm.gvariant)
            type
            mkVariant mkTuple mkUint32 mkString mkBoolean mkArray;

        inherit (type)
            tupleOf uint32 string boolean arrayOf double;


        # reference:
        # https://github.com/GNOME/libgweather/blob/7f9f1e7510ddfb514de33f885d97ee64ac7f88a8/libgweather/gweather-location.c#L1423

        mkGWeatherLocation = {
            name,           # string
            stationCode,    # string
            isCity,         # boolean
            realLoc,        # Either (tupleOf [double double]) null
            parent ? null,  # Either (tupleOf [double double]) null
        }: let

            optionalPair = maybePair: let
                val = if maybePair == null
                    then []
                    else [(mkTuple maybePair)];
            in
                mkArray (tupleOf [double double]) val;

            format = 2;
        in
            # type: (v)
            # inner type: (uv)
            # inner type: (ssba(dd)a(dd))
                
            mkVariant (
                mkTuple [
                    (mkUint32 format)
                    (mkVariant (
                        mkTuple [
                            (mkString name)
                            (mkString stationCode)
                            (mkBoolean isCity)
                            (optionalPair realLoc)
                            (optionalPair parent)]))]);
    in {
        "org/gnome/shell/weather" = {
            locations = mkArray type.variant [
                (mkGWeatherLocation {
                    name = "Champaign-Urbana, IL";
                    stationCode = "KCMI";
                    isCity = false;
                    realLoc = [ 0.69869408078930939 (-1.5406603025593635) ];
                })
            ];
        };

        "org/gnome/Weather".locations = self."org/gnome/shell/weather".locations;

        "org/gnome/GWeather4" = {
            temperature-unit = "centigrade";
        };

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

        "org/gnome/desktop/interface" = {
            enable-animations = false;
        };

        "org/gnome/desktop/wm/preferences" = {
            focus-mode = "sloppy";
            resize-with-right-button = true;
        };

        "org/gnome/mutter" = {
            dynamic-workspaces = true;
        };

        "org/gnome/desktop/peripherals/mouse" = {
            accel-profile = "flat";
        };

        "org/gnome/settings-daemon/plugins/power" = {
            idle-dim = false;

            sleep-inactive-battery-type = "suspend";
            sleep-inactive-battery-timeout = 1800;

            sleep-inactive-ac-type = "nothing";
        };

        "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = true;
        };

        "org/gnome/desktop/session" = {
            idle-delay = mkUint32 600;
        };

        "org/gnome/desktop/input-sources" = let
            inherit (type) string tupleOf;

            mkStrPairArray = list:
                mkArray (tupleOf [string string]) (map mkTuple list);
        in {
            sources = mkStrPairArray [
                [ "xkb" "us" ]
                [ "xkb" "semimak-jq" ]
                [ "xkb" "semimak-jqa" ]
                [ "xkb" "ru" ]
                [ "ibus" "mozc-jp" ]
            ];

            xkb-options = mkArray string [
                "terminate:ctrl_alt_bksp" "caps:escape"
            ];
        };

        "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "list-view";
            show-create-link = true;
            show-delete-permanently = true;
        };

        "org/gnome/nautilus/list-view" = {
            default-zoom-level = "small";
            use-tree-view = true;
        };

        "org/gtk/settings/file-chooser" = {
            sort-directories-first = true;
            sort-column = "modified";
            sort-order = "descending";
        };

        "org/gtk/gtk4/settings/file-chooser" = self."org/gtk/settings/file-chooser";

        "org/gnome/tweaks".show-extensions-notice = false;
        "ca/desrt/dconf-editor".show-warning = false;
    }; in self;
}