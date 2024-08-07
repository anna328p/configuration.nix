{ pkgs, lib, config, ... }:

{
    programs.gnome-terminal = let
        scheme = config.colorScheme;
        profileUUID = "7dc9e410-f2aa-47f5-9bf1-e65d55f704a9"; # uuidgen

        colorsPrefixed = lib.mapAttrs (_: v: "#${v}") scheme.palette;
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
                    c.base00 c.base08 c.base0B c.base0A c.base0D c.base0E c.base0C c.base05
                    c.base03 c.base08 c.base0B c.base0A c.base0D c.base0E c.base0C c.base07
                ];
            };
        };
    };
}