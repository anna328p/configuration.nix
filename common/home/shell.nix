{ ... }:

{
	programs.zsh = {
		enable = true;
		enableAutosuggestions = true;
		enableCompletion = true;
		# enableVteIntegration = true;
		autocd = true;
		dotDir = ".config/zsh";

		envExtra = ''
			export PATH=$HOME/bin:$HOME/.local/bin:$PATH
			export CDPATH=.:$HOME:$CDPATH

			export DEFAULT_USER=$(whoami)
			export GPG_TTY=$(tty)
		'';

		history = {
			extended = true;
			path = ".local/share/zsh/zsh_history";
			save = 100000;
			size = 100000;
		};

		initExtra = ''
			setopt GLOB_DOTS

			for i in util autopushd escesc; do
				source ${files/zsh/snippets}/$i.zsh
			done
		'';

		dirHashes = {
			w = "$HOME/work";
		};

		shellAliases = {
			ls = "exa";
			open = "xdg-open";
			":w" = "sync";
			":q" = "exit";
			":wq" = "sync; exit";
			nbs = "time sudo nixos-rebuild switch";
			nbsu = "time sudo nixos-rebuild switch --upgrade";
			nsn = "nix search nixpkgs";
		};

		prezto = {
			enable = true;
			extraModules = [ "attr" "stat" "zpty" ];
			extraFunctions = [ "zargs" "zmv" ];

			pmodules = [
				"environment"
				"terminal"
				"editor"
				"history"
				"directory"
				"spectrum"
				"helper"
				"utility"
				"completion"
				"prompt"
				"autosuggestions"
				"directory"
				"git"
				"history-substring-search"
				"rails"
				"ruby"
				"ssh"
				"syntax-highlighting"
				"tmux"
			];

			autosuggestions.color = "fg=blue";
			editor.dotExpansion = true;
			prompt.theme = "agnoster";
			syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" "line" "root" ];

			terminal = {
				autoTitle = true;
				multiplexerTitleFormat = "%s";
			};

			tmux = {
				autoStartLocal = true;
				autoStartRemote = true;
				defaultSessionName = "theseus";
			};

			utility.safeOps = false;
		};
	};
	
	programs.direnv = {
		enable = true;
		nix-direnv = {
		  enable = true;
		};
		enableZshIntegration = true;
	};
}

# vim: set ts=4 sw=4 noet :
