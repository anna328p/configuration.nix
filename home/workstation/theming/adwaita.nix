{ config, local-lib, ... }:

let
    inherit (local-lib) colors;

    scheme = config.colorScheme;
    formatted = colors.prefixHash scheme.palette;

    c = formatted;

    defs = rec {
        accent_bg_color = c.base0C;
        accent_fg_color = c.base05;

        destructive_bg_color = c.base08;
        destructive_fg_color = c.base05;

        success_bg_color = c.base0B;
        success_fg_color = c.base05;

        warning_bg_color = c.base0A;
        warning_fg_color = c.base05;

        error_bg_color = destructive_bg_color;
        error_fg_color = c.base05;

        window_bg_color = c.base00;
        window_fg_color = c.base05;

        view_bg_color = c.base01;
        view_fg_color = c.base05;

        headerbar_bg_color       = c.base01;
        headerbar_fg_color       = c.base05;
        headerbar_border_color   = c.base02;
        headerbar_backdrop_color = c.base00;

        sidebar_bg_color       = headerbar_bg_color;
        sidebar_fg_color       = headerbar_fg_color;
        sidebar_border_color   = headerbar_border_color;
        sidebar_backdrop_color = headerbar_backdrop_color;

        card_bg_color = c.base01;
        card_fg_color = c.base05;

        dialog_bg_color = c.base01;
        dialog_fg_color = c.base05;

        popover_bg_color = c.base01;
        popover_fg_color = c.base05;
    };

    cssColors = colors.genDecls (k: v: "@define-color ${k} ${v};") defs;

    css = /* css */ ''
        ${cssColors}

        .nautilus-window.background { background-color: ${c.base00} !important; }
    '';
in {
    xdg.configFile = {
        "gtk-3.0/gtk.css".text = css;
        "gtk-4.0/gtk.css".text = css;
    };
}