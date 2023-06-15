{ ... }:

{
	home.shellAliases = let
		addT = nbs: nbs + " --show-trace";
		addK = nbs: nbs + " --keep-going";
		addF = nbs: nbs + " --fast";
	in rec {
		open = "xdg-open";

		nbs = "time nixos-rebuild switch --use-remote-sudo"
			+ " --flake 'path:/etc/nixos'";

		nbst = addT nbs;
		nbsk = addK nbs;
		nbsf = addF nbs;

		nbstf = addF nbst;
		nbsft = addT nbsf;
		nbskf = addF nbsk;
		nbsfk = addK nbsf;

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
