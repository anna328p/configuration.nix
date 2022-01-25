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

			{
				plugin = resurrect;
				extraConfig = ''
					set -g @resurrect-strategy-nvim 'session'
					set -g @resurrect-processes 'ssh telnet mosh-client nvim dmesg nix'
					set -g @resurrect-capture-pane-contents 'on'
				'';
			}

			{
				plugin = continuum;
				extraConfig = ''
					set -g @continuum-restore on
					set -g @continuum-save-interval '10' # minutes
				'';
			}
		];

		terminal = "xterm-256color";

		extraConfig = ''
			setw -g alternate-screen on
			set-option -ga terminal-overrides ",xterm-termite:Tc,xterm-256color:Tc"
			set-option -ga status-style fg=black,bg=blue
			set-option -ga clock-mode-colour white
			bind-key -n C-j detach
			set -g mouse on
		'';
	};
}

# vim: set ts=4 sw=4 noet :
