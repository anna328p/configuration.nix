{ config, pkgs, lib, flakes, ... }:

{
	imports = [
		flakes.nix-colors.homeManagerModule

		./themes.nix

		./terminal.nix

		./tmux.nix
		./shell.nix
		./editor.nix

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

		username = "anna";

		stateVersion = "22.05";
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
