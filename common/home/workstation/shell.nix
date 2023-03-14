{ ... }:

{
	home.shellAliases = {
		open = "xdg-open";

		nbs = "time nixos-rebuild switch --use-remote-sudo";
		nbst = "time nixos-rebuild switch --use-remote-sudo --show-trace";
		nbsk = "time nixos-rebuild switch --use-remote-sudo --keep-going";
		nbsf = "time nixos-rebuild switch --use-remote-sudo --fast";

		nsn = "nix search nixpkgs";
	};

	programs.zsh = {
		cdpath = [ "$HOME" ];

		enableVteIntegration = true;

		envExtra = ''
			export GPG_TTY=$(tty)
		'';

		dirHashes = {
			w = "$HOME/work";
			en = "/etc/nixos";
		};

		prezto = {
			pmodules = [
				"tmux"
				"syntax-highlighting"
				"autosuggestions"
			];

			tmux = {
				autoStartLocal = true;
				autoStartRemote = true;
			};

			syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" "line" "root" ];
			autosuggestions.color = "fg=blue";
		};
	};
	
	programs.direnv = {
		enable = true;
		nix-direnv.enable = true;
		enableZshIntegration = true;
	};
}
