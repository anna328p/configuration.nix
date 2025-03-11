{ config, pkgs, flakes, lib, local-lib, ... }:

{
    dconf.settings = let
        scheme = config.colorScheme;

        nix-colors-lib = flakes.nix-colors.lib-contrib { inherit pkgs; };

        wallpaper-path = nix-colors-lib.nixWallpaperFromScheme {
            inherit scheme;
            width = 3840;
            height = 2160;
            logoScale = 4.0;
        };

        byVariant' = local-lib.colors.byVariant scheme.variant;
    in {
        "org/gnome/desktop/interface" = {
            font-antialiasing = lib.mkDefault "rgba";
            font-hinting = lib.mkDefault "slight";

            color-scheme = byVariant' "default" "prefer-dark";

            enable-animations = false;
        };

        "org/gnome/desktop/background" = rec {
            picture-uri = "file://${wallpaper-path}";
            picture-uri-dark = picture-uri;
            primary-color = "#${scheme.palette.base03}";
        };

        "org/gnome/desktop/screensaver" = {
            picture-uri = "file://${wallpaper-path}";
            primary-color = "#${scheme.palette.base03}";
        };
    };
}