{ pkgs, config, local-lib, ... }:


let
    inherit (local-lib) colors;

    byVariant' = colors.byVariant config.colorScheme.variant;

in {
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
            package = [ pkgs.adwaita-qt pkgs.adwaita-qt6 ];

            name = byVariant' "adwaita" "adwaita-dark";
        };
    };
}