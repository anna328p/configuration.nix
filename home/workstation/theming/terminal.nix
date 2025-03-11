{ pkgs, lib, config, ... }:

let
    scheme = config.colorScheme;
    colorsPrefixed = lib.mapAttrs (_: v: "#${v}") scheme.palette;
in {
    programs.ghostty = {
        enable = true;

        themes.${scheme.slug} = let
            c = colorsPrefixed;
        in {
            background = c.base00;
            foreground = c.base05;

            cursor-color = c.base05;
            cursor-text = c.base02;

            selection-background = c.base04;
            selection-foreground = c.base01;

            palette = [
                " 0=${c.base00}" " 1=${c.base08}"
                " 2=${c.base0B}" " 3=${c.base0A}"
                " 4=${c.base0D}" " 5=${c.base0E}"
                " 6=${c.base0C}" " 7=${c.base05}"

                " 8=${c.base03}" " 9=${c.base08}"
                "10=${c.base0B}" "11=${c.base0A}"
                "12=${c.base0D}" "13=${c.base0E}"
                "14=${c.base0C}" "15=${c.base07}"
            ];
        };

        settings = {
            theme = scheme.slug;

            font-family = [
                config.misc.fonts.monospace.name
                "DejaVu Sans Mono"
            ];

            font-size = config.misc.fonts.monospace.size;
            font-variation = "wdth=120";
            # adjust-cell-width = "-5%";

            clipboard-read = "allow";
            link-url = true;
            shell-integration = "none";

            linux-cgroup = "single-instance";

            window-decoration = false;
            gtk-titlebar = false;
            # gtk-adwaita = false; # broken
            window-padding-balance = true;
        };
    };

    programs.gnome-terminal = let
        profileUUID = "7dc9e410-f2aa-47f5-9bf1-e65d55f704a9"; # uuidgen
    in {
        enable = true;

        themeVariant = scheme.variant;

        profile.${profileUUID} = {
            visibleName = scheme.name;
            default = true;

            showScrollbar = false;

            colors = let c = colorsPrefixed; in {
                backgroundColor = c.base00;
                foregroundColor = c.base05;

                cursor.background = c.base05;
                cursor.foreground = c.base02;

                highlight.background = c.base04;
                highlight.foreground = c.base01;

                palette = [
                    c.base00 c.base08 c.base0B c.base0A
                    c.base0D c.base0E c.base0C c.base05

                    c.base03 c.base08 c.base0B c.base0A
                    c.base0D c.base0E c.base0C c.base07
                ];
            };
        };
    };
}