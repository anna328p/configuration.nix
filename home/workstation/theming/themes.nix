{ lib, pkgs, config, local-lib, ... }:


let
    inherit (local-lib) colors;

    byVariant' = colors.byVariant config.colorScheme.variant;

in {
    gtk = {
        theme = {
            package = pkgs.adw-gtk3;
            name = byVariant' "adw-gtk3" "adw-gtk3-dark";
        };

        gtk4.theme = null;

        gtk2.extraConfig = let
            themeName = byVariant' "Adwaita" "Adwaita-dark";
        in ''
            gtk-theme-name="${themeName}"
        '';
    };


    # TODO: https://github.com/nix-community/home-manager/issues/7113
    xdg.configFile."gtk-4.0/gtk.css" = lib.mkForce { text = config.gtk.gtk4.extraCss; };

    qt = {
        enable = true;
        platformTheme.name = "adwaita";

        style = {
            package = [ pkgs.adwaita-qt pkgs.adwaita-qt6 ];

            name = byVariant' "adwaita" "adwaita-dark";
        };
    };
}