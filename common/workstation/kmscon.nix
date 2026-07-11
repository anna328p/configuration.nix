{ config, lib, L, flakes, ... }:

let
    hmcfg = config.home-manager.users.anna;
    monospaceFont = hmcfg.misc.fonts.monospace;
in {
    fonts.packages = [ monospaceFont.package ];

    services.kmscon = {
        enable = false;

        config = let
            inherit (lib) mapAttrs;

            inherit (flakes.nix-colors.lib-core.conversions) hexToRGBString;
            mkColorStrings = mapAttrs (_: hexToRGBString ", ");

            c = mkColorStrings hmcfg.colorScheme.palette;

        in {
            hwaccel = true;

            font-size = monospaceFont.size;
            font-name = monospaceFont.name;

            palette = "custom";

            palette-black = c.base00;
            palette-red = c.base08;
            palette-green = c.base0B;
            palette-yellow = c.base0A;
            palette-blue = c.base0D;
            palette-magenta = c.base0E;
            palette-cyan = c.base0C;
            palette-light-grey = c.base05;
            palette-dark-grey = c.base03;
            palette-light-red = c.base08;
            palette-light-green = c.base0B;
            palette-light-yellow = c.base0A;
            palette-light-blue = c.base0D;
            palette-light-magenta = c.base0E;
            palette-light-cyan = c.base0C;
            palette-white = c.base07;

            palette-background = c.base00;
            palette-foreground = c.base05;
        };
    };
}