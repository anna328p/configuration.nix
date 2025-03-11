{ pkgs, ... }:

{
    fonts.fontconfig.enable = true;

    misc.fonts = {
        enable = true;

        sans-serif = {
            package = pkgs.source-sans;
            name = "Source Sans 3";
            size = 10.8;
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