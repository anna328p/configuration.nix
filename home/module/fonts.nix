{ config, lib, L, ... }:

with lib; let
    cfg = config.misc.fonts;

    mkFontOption = L.mkGenericOption { } hm.types.fontType;
in {
    options.misc.fonts = {
        enable = mkEnableOption "Font management";
        ui = mkFontOption "Font used in system applications" {};
        document = mkFontOption "Font used for documents" {};
        monospace = mkFontOption "Font used for terminals and code" {};
    };

    config = mkIf cfg.enable {
        home.packages = concatMap (L.optionalAttr "package") [
            cfg.ui
            cfg.document
            cfg.monospace
        ];

        gtk.enable = true;
        gtk.font = cfg.ui;

        dconf.settings = let
            fontDesc = opt: "${opt.name} ${toString opt.size}";
        in {
            "org/gnome/desktop/interface" = {
                document-font-name = fontDesc cfg.document;
                monospace-font-name = fontDesc cfg.monospace;
            };

            "org/gnome/desktop/wm/preferences" = {
                titlebar-font = fontDesc cfg.ui;
            };
        };
    };
}
