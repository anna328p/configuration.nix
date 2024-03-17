{ config, lib, L, flakes, ... }:

{
    services.kmscon = let
        hmcfg = config.home-manager.users.anna;
        monospaceFont = hmcfg.misc.fonts.monospace;
    in {
        enable = true;
        hwRender = true;

        fonts = [
            { inherit (monospaceFont) name package; }
        ];

        extraConfig = with lib; with L; let
            toLine = k: v: "${k}=${toString v}";

            mkConf = o concatLines (mapAttrsToList toLine);

            inherit (flakes.nix-colors.lib-core.conversions) hexToRGBString;
            mkColorStrings = mapAttrs (_: hexToRGBString ", ");

            colors = mkColorStrings hmcfg.colorScheme.palette;

        in with colors; mkConf {
            font-size = monospaceFont.size;

            palette = "custom";

            palette-black = base00;
            palette-red = base08;
            palette-green = base0B;
            palette-yellow = base0A;
            palette-blue = base0D;
            palette-magenta = base0E;
            palette-cyan = base0C;
            palette-light-grey = base05;
            palette-dark-grey = base03;
            palette-light-red = base08;
            palette-light-green = base0B;
            palette-light-yellow = base0A;
            palette-light-blue = base0D;
            palette-light-magenta = base0E;
            palette-light-cyan = base0C;
            palette-white = base07;

            palette-background = base00;
            palette-foreground = base05;
        };
    };
}