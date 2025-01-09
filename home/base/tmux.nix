{ pkgs, lib, config, ... }:

{
    programs.tmux = {
        enable = true;
        aggressiveResize = true;
        clock24 = true;
        escapeTime = 50;
        historyLimit = 300000;
        newSession = true;
        sensibleOnTop = true;
        focusEvents = true;

        plugins = let
            t = pkgs.tmuxPlugins;
        in [
            t.sensible t.yank
        ];

        terminal = "tmux-256color";

        extraConfig = ''
            bind-key -n C-j detach

            set-option -ga terminal-features \
                ",*ghostty:clipboard:cstyle:extkeys:focus:hyperlinks:margins:osc7:overline:RGB:strikethrough:sync:usstyle:"

            set-option -ga terminal-features ",xterm-256color:hyperlinks:RGB:"

            set -g mouse on
            set -g set-titles on
            setw -g alternate-screen on
            set-option -ga clock-mode-colour white

        '' + (lib.optionalString (config.misc.buildType == "base") ''
            set-option -g status-style fg=black,bg=blue
        '');
    };
}