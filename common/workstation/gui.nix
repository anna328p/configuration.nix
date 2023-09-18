{ config, pkgs, lib, ... }:

{
    # IME support
    i18n = {
        supportedLocales = [ "en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
        inputMethod = {
            enabled = "ibus";
            ibus.engines = with pkgs.ibus-engines; [ mozc ];
        };
    };

    environment.systemPackages = with pkgs; [
        # Clipboard management
        xclip

        # Automation
        ydotool

        # Color picker
        gcolor3

        # GTK theme
        adw-gtk3

        # Image rendering
        libjxl-with-plugins
    ] ++ (with pkgs.gnome; [
        # GNOME addons
        gnome-sound-recorder gnome-tweaks gnome-music
    ]) ++ (with pkgs.gnomeExtensions; [
        gsconnect
        brightness-control-using-ddcutil
        sensory-perception
        compiz-windows-effect
        appindicator
    ]);

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

        packages = with pkgs; [
            source-code-pro source-sans source-serif
            noto-fonts noto-fonts-cjk noto-fonts-emoji-blob-bin
            liberation_ttf open-sans corefonts

        ] ++ (lib.optionals config.misc.buildFull (with pkgs; [
            google-fonts
        ]));
    };

    services = {
        xserver = {
            enable = true;
            layout = "us";

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
                        "firefox-devedition" "discord" "org.telegram.desktop"
                        "org.gnome.Nautilus" "org.gnome.Terminal"
                        "logseq"
                    ];
                };
            };

            displayManager.gdm = {
                enable = true;
                wayland = true;
            };

            libinput.enable = true;
            wacom.enable = true;

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

        gnome-terminal.enable = true;
    };


    # Allow using extensions.gnome.org in firefox
    nixpkgs.config = {
        firefox.enableGnomeExtensions = true;
    };
}