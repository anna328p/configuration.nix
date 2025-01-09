{ lib, config, L, ... }:

let
    scheme = config.colorScheme;
    colorsPrefixed = lib.mapAttrs (_: v: "#${v}") scheme.palette;

    base16Config = let
        fn = name: value: "set -g @${name} \"${value}\"";
    in
        L.concatLines (L.mapSetEntries fn colorsPrefixed);
in {
    programs.tmux = {
        extraConfig = let
            sg = v: "set-option -g ${v}";
            sga = v: "set-option -ga ${v}";

            wsf = "window-status-format";
            wscf = "window-status-current-format";
            sl = "status-left";
            sr = "status-right";
        in ''
            ${base16Config}

            set -g status-style "fg=#{@base04},bg=#{@base01}"

            set -g window-status-current-style 'fg=#{@base05},bg=#{@base02}'

            set -g window-status-separator ""

            ${sg wsf}  " "
            ${sga wsf} "#[bold fg=#{@base04}]#{window_index}#[default]"
            ${sga wsf} "#[fg=#{@base03}]:#[default]"
            ${sga wsf} "#{window_name}"
            ${sga wsf} "#[fg=#{@base05} bold]#{window_flags}#[default]"
            ${sga wsf} " "

            ${sg wscf}  " "
            ${sga wscf} "#[bold fg=#{@base05}]#{window_index}#[default]"
            ${sga wscf} ":"
            ${sga wscf} "#[fg=#{@base05}]#{window_name}#[default]"
            ${sga wscf} "#{window_flags}"
            ${sga wscf} " "

            ${sg sl}  ""
            ${sga sl} "#{?client_prefix,"
                ${sga sl} "#[fg=#{@base00} bg=#{@base04}]"
            ${sga sl} ","
                ${sga sl} "#[fg=#{@base04} bg=#{@base02}]"
            ${sga sl} "}"
            ${sga sl} " #{session_name} "
            ${sga sl} "#[default]"
            ${sga sl} " "

            set -g status-right-length 60

            ${sg sr}  ""
            ${sga sr} "#{?client_prefix,#[fg=#{@base03}]#{prefix}#[default],} "
            ${sga sr} "#[fg=#{@base05} bg=#{@base02}]"
            ${sga sr} " #{=|39|#[bold]+#[nobold]:pane_title} "
            ${sga sr} "#[default]"
            ${sga sr} " %Y-%m-%d %H:%M "
        '';
    };
}