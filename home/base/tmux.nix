{ pkgs, ... }:

{
    programs.tmux = {
        enable = true;
        aggressiveResize = true;
        clock24 = true;
        escapeTime = 50;
        historyLimit = 300000;
        newSession = true;
        sensibleOnTop = true;

        plugins = let
            t = pkgs.tmuxPlugins;
        in [
            t.sensible t.yank
        ];

        terminal = "tmux-256color";

        extraConfig = ''
            setw -g alternate-screen on
            set-option -ga terminal-overrides ",xterm-256color:RGB"
            set-option -ga status-style fg=black,bg=blue
            set-option -ga clock-mode-colour white
            bind-key -n C-j detach
            set -g mouse on
        '';
    };
}