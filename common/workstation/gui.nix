{ config, pkgs, lib, ... }:

{
    # IME support
    i18n = {
        supportedLocales = [
            "en_US.UTF-8/UTF-8"
            "ja_JP.UTF-8/UTF-8"
            "ko_KR.UTF-8/UTF-8"
        ];

        inputMethod = {
            enable = true;
            type = "ibus";

            ibus.engines = let
                i = pkgs.ibus-engines;
            in
                [ i.mozc i.hangul ];
        };
    };

    environment.systemPackages = let
        p = pkgs;
        e = pkgs.gnomeExtensions;
    in [
        # Terminal
        p.ghostty

        # Clipboard management
        p.wl-clipboard
        p.wl-clipboard-x11

        # Automation
        p.ydotool

        # Color picker
        p.gcolor3

        # GTK theme
        p.adw-gtk3

        # Image rendering
        p.libjxl-with-plugins

        # GNOME addons
        p.gnome-sound-recorder p.gnome-tweaks p.gnome-music

        # GNOME extensions
        e.brightness-control-using-ddcutil
        e.compiz-windows-effect
        e.appindicator
        e.transmission-daemon-indicator-ng
        e.blur-my-shell
        e.battery-time-2
    ];

    environment.variables = {
        # Force Wayland support
        MOZ_USE_XINPUT2 = "1";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";

        # Misc
        CALIBRE_USE_DARK_PALETTE = "1";
        SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
    };

    # System fonts
    fonts = {
        enableDefaultPackages = true;

        packages = let p = pkgs; in [
            p.source-code-pro p.source-sans p.source-serif
            p.noto-fonts p.noto-fonts-cjk-sans p.noto-fonts-emoji-blob-bin
            p.liberation_ttf p.open-sans p.corefonts

        ] ++ (lib.optionals config.misc.buildFull [
            p.google-fonts
        ]);
    };

    services = {
        xserver = {
            enable = true;

            desktopManager = {
                xterm.enable = false;

                gnome = {
                    enable = true;

                    # Declaratively configure dash
                    favoriteAppsOverride = let
                        genList = lib.concatMapStringsSep ", " (s: "'${s}.desktop'");

                        overrideList = names: ''
                            [org.gnome.shell]
                            favorite-apps=[ ${genList names} ]
                        '';
                    in overrideList [
                        "firefox-developer-edition" "discord"
                        "org.telegram.desktop"
                        "org.gnome.Nautilus" "com.mitchellh.ghostty"
                        "logseq"
                    ];
                };
            };

            displayManager.gdm = {
                enable = true;
                wayland = true;
            };

            wacom.enable = true;

            xkb = {
                layout = "us";

                extraLayouts = let
                    mkLayout = desc: file: {
                        description = "English (${desc})";
                        languages = [ "eng" ];
                        symbolsFile = file;
                    };
                in {
                    semimak-jq = mkLayout "Semimak JQ" files/symbols/semimak-jq;
                    semimak-jqa = mkLayout "Semimak JQ, angle mod" files/symbols/semimak-jqa;
                    canary = mkLayout "Canary" files/symbols/canary;
                };
            };
        };

        libinput.enable = true;

        gnome.core-developer-tools.enable = true;
    };

    programs = {
        # Mobile syncing
        kdeconnect = {
            enable = true;
            package = pkgs.gnomeExtensions.gsconnect;
        };

        # Email client
        geary.enable = true;

        # Use Papers instead of evince
        evince.package = pkgs.papers;
    };

    # Allow using extensions.gnome.org in firefox
    nixpkgs.config = {
        firefox.enableGnomeExtensions = true;
    };

    xdg.terminal-exec = {
        enable = true;
        settings.default = [ "com.mitchellh.ghostty.desktop" ];
    };
}