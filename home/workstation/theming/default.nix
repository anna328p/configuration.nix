{ pkgs, config, local-lib, ... }:

let
    inherit (local-lib) colors;

    byVariant' = colors.byVariant config.colorScheme.variant;

in {
    imports = [
        ./gnome.nix
        ./witchhazel.nix
        ./adwaita.nix
        ./terminal.nix
        ./firefox.nix
        ./discord.nix
    ];

    # for testing other themes:
    # colorScheme = flakes.nix-colors.colorSchemes.solarized-light;

    fonts.fontconfig.enable = true;

    misc.fonts = {
        enable = true;

        ui = {
            package = pkgs.source-sans;
            name = "Source Sans 3";
            size = 10.8;
        };

        document = {
            package = pkgs.source-serif;
            name = "Source Serif 4";
            size = 10.8;
        };

        monospace = {
            package = pkgs.source-code-pro;
            name = "Source Code Pro";
            size = 11.8;
        };
    };

    gtk = {
        theme = {
            package = pkgs.adw-gtk3;
            name = byVariant' "adw-gtk3" "adw-gtk3-dark";
        };

        gtk2.extraConfig = "gtk-theme-name=\"${byVariant' "Adwaita" "Adwaita-dark"}\"";
    };

    qt = {
        enable = true;
        platformTheme.name = "adwaita";

        style = {
            package = pkgs.adwaita-qt;
            name = byVariant' "adwaita" "adwaita-dark";
        };
    };
}