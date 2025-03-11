{ config, L, lib, local-lib, ... }:

let
    inherit (builtins)
        concatMap
        toString
        ;

    inherit (lib)
        hm
        mkEnableOption
        mkIf
        ;

    cfg = config.misc.fonts;

    mkFontOption = local-lib.mkGenericOption { } hm.types.fontType;
in {
    options.misc.fonts = {
        enable = mkEnableOption "Font management";

        ui = mkFontOption "Font used in system applications" {
            default = cfg.sans-serif;
        };

        document = mkFontOption "Font used for documents" {
            default = cfg.serif;
        };

        sans-serif = mkFontOption "Sans-serif font for text display" { };
        serif = mkFontOption "Serif font for text display" { };
        monospace = mkFontOption "Font used for terminals and code" { };
    };

    config = mkIf cfg.enable {
        assertions = [
            {
                assertion = cfg.sans-serif != null;
                message = "misc.fonts.sans-serif must be defined";
            }
            {
                assertion = cfg.serif != null;
                message = "misc.fonts.serif must be defined";
            }
            {
                assertion = cfg.monospace != null;
                message = "misc.fonts.monospace must be defined";
            }
        ];

        home.packages = concatMap
            (entry: if entry.package != null then [ entry.package ] else [ ])
            [ cfg.ui cfg.sans-serif cfg.serif cfg.document cfg.monospace ];

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

        fonts.fontconfig = {
            enable = true;
            defaultFonts = {
                monospace = [ cfg.monospace.name ];
                serif = [ cfg.serif.name ];
                sansSerif = [ cfg.sans-serif.name ];
            };
        };
    };
}