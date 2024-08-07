{ config, local-lib, ... }:

let
    inherit (local-lib) colors;

    scheme = config.colorScheme;
    formatted = colors.prefixHash scheme.palette;

    defs = let c = formatted; in rec {
        accent_color    = c.base0C;
        accent_bg_color = accent_color;
        accent_fg_color = c.base05;

        destructive_color    = c.base08;
        destructive_bg_color = destructive_color;
        destructive_fg_color = c.base05;

        success_color    = c.base0B;
        success_bg_color = success_color;
        success_fg_color = c.base05;

        warning_color    = c.base0A;
        warning_bg_color = warning_color;
        warning_fg_color = c.base05;

        error_color    = destructive_color;
        error_bg_color = error_color;
        error_fg_color = c.base05;

        window_bg_color = c.base00;
        window_fg_color = c.base05;

        view_bg_color = c.base01;
        view_fg_color = c.base05;

        headerbar_bg_color = c.base01;
        headerbar_fg_color = c.base05;
        headerbar_border_color = c.base04;
        headerbar_backdrop_color = c.base00;

        card_bg_color = c.base01;
        card_fg_color = c.base05;

        dialog_bg_color = c.base01;
        dialog_fg_color = c.base05;

        popover_bg_color = c.base01;
        popover_fg_color = c.base05;
    };

    css = colors.genDecls (k: v: "@define-color ${k} ${v};") defs;
in {
    xdg.configFile = {
        "gtk-3.0/gtk.css".text = css;
        "gtk-4.0/gtk.css".text = css;
    };
}