{ config, pkgs, ... }:

{
	home.shellAliases = {
		ls = "exa";
		open = "xdg-open";

		":w" = "sync";
		":q" = "exit";
		":wq" = "sync; exit";

		nbs = "time nixos-rebuild switch --use-remote-sudo";
		nbst = "time nixos-rebuild switch --use-remote-sudo --show-trace";
		nbsk = "time nixos-rebuild switch --use-remote-sudo --keep-going";
		nbsf = "time nixos-rebuild switch --use-remote-sudo --fast";

		nsn = "nix search nixpkgs";
	};

	home.file.".config/zsh/.p10k.zsh".source = files/zsh/p10k.zsh;

	programs.zsh = {
		enable = true;
		dotDir = ".config/zsh";

		cdpath = [ "$HOME" ];

		enableCompletion = true;
		enableVteIntegration = true;

		sessionVariables = {
			EDITOR = "nvim";
			VISUAL = "nvim";
		};

		envExtra = ''
			export DEFAULT_USER=$(whoami)
			export GPG_TTY=$(tty)
		'';

		history = {
			expireDuplicatesFirst = true;
			extended = true;
			path = ".local/share/zsh/zsh_history";
			save = 100000;
			size = 100000;
		};

		initExtraFirst = ''
			source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
		'';

		initExtra = ''
			zmodload zsh/attr
			zmodload zsh/stat
			zmodload zsh/zpty
			
			autoload zmv
			autoload zargs
			
			setopt GLOB_DOTS
			for i in util escesc autopushd; do
				source ${files/zsh/snippets}/$i.zsh
			done
		'';

		dirHashes = {
			w = "$HOME/work";
			en = "/etc/nixos";
		};

		prezto = {
			enable = true;

			pmodules = [
				"environment"
				"editor"
				"history"
				"directory"
				"spectrum"
				"helper"
				"utility"
				"completion"
				"syntax-highlighting"
				"history-substring-search"
				"autosuggestions"
				"tmux"
			];

			autosuggestions.color = "fg=blue";
			editor.dotExpansion = true;
			syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" "line" "root" ];

			tmux = {
				autoStartLocal = true;
				autoStartRemote = true;
			};

			utility.safeOps = false;
		};
	};
	
	programs.direnv = {
		enable = true;
		nix-direnv.enable = true;
		enableZshIntegration = true;
	};
}

# vim: set ts=4 sw=4 noet :
