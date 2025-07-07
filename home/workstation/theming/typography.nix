{ pkgs, ... }:

{
    fonts.fontconfig.enable = true;

    misc.fonts = {
        enable = true;

        sans-serif = {
            package = pkgs.adwaita-fonts;
            name = "Adwaita Sans";
            size = 10;
        };

        serif = {
            package = pkgs.libertinus;
            name = "Libertinus Serif";
            size = 12;
        };

        monospace = {
            package = pkgs.google-fonts.override { fonts = [ "Inconsolata" ]; };
            name = "Inconsolata";
            size = 12.5;
        };
    };
}