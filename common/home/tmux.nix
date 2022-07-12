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

		plugins = with pkgs.tmuxPlugins; [
			sensible yank
		];

		terminal = "xterm-256color";

		extraConfig = ''
			setw -g alternate-screen on
			set-option -ga terminal-overrides ",xterm-256color:Tc"
			set-option -ga status-style fg=black,bg=blue
			set-option -ga clock-mode-colour white
			bind-key -n C-j detach
			set -g mouse on
		'';
	};
}

# vim: set ts=4 sw=4 noet :
