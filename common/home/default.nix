{ config, pkgs, lib, ... }:

{
	imports = [
		 ./editor.nix
		 ./shell.nix
		 ./tmux.nix
		 ./themes.nix
		 ./ssh.nix
		 ./git.nix
	];

	home = {
		file.bin = {
			source = files/bin;
			target = ".local/bin";
			recursive = true;
		};

		sessionVariables = {
			NIX_AUTO_RUN = 1;
			MOZ_USE_XINPUT2 = 1;
		};

		sessionPath = [ "$HOME/.local/bin" ];

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

		username = "anna";
	};

	xdg = {
		enable = true;
		userDirs.enable = true;
	};

	services = {
		fluidsynth.enable = true;
	};

	programs = {
		obs-studio.enable = true;
	};
}

# vim: set ts=4 sw=4 noet :
