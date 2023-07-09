{ lib, config, pkgs, flakes, L, ... }:

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

        byKind' = L.colors.byKind scheme.kind;
    in with lib.hm.gvariant; {
        "org/gnome/desktop/interface" = {
            font-antialiasing = "rgba";
            font-hinting = "slight";

            color-scheme = byKind' "default" "prefer-dark";

            enable-animations = false;
        };

        "org/gnome/desktop/background" = rec {
            picture-uri = "file://${wallpaper-path}";
            picture-uri-dark = picture-uri;
            primary-color = "#${scheme.colors.base03}";
        };

        "org/gnome/desktop/screensaver" = {
            picture-uri = "file://${wallpaper-path}";
            primary-color = "#${scheme.colors.base03}";
        };
    };
}
