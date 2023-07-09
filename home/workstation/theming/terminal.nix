{ pkgs, lib, config, ... }:

{
    programs.gnome-terminal = let
        scheme = config.colorScheme;
        profileUUID = "7dc9e410-f2aa-47f5-9bf1-e65d55f704a9"; # uuidgen

        colorsPrefixed = lib.mapAttrs (_: v: "#${v}") scheme.colors;
    in {
        enable = true;

        themeVariant = scheme.kind;

        profile.${profileUUID} = {
            visibleName = scheme.name;
            default = true;

            showScrollbar = false;

            colors = with colorsPrefixed; {
                backgroundColor = base00;
                foregroundColor = base05;

                cursor.background = base05;
                cursor.foreground = base02;

                highlight.background = base04;
                highlight.foreground = base01;

                palette = [
                    base00 base08 base0B base0A base0D base0E base0C base05
                    base03 base08 base0B base0A base0D base0E base0C base07
                ];
            };
        };
    };
}
