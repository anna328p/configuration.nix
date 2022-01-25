{ config, pkgs, lib, ... }: {
	imports = [
		 ./editor.nix
		 ./shell.nix
		 ./tmux.nix
		 ./themes.nix
		 ./ssh.nix
	];

	home.file.bin = {
		source = files/bin;
		target = ".local/bin";
		recursive = true;
	};

	home.sessionVariables = {
		NIX_AUTO_RUN = 1;
		MOZ_USE_XINPUT2 = 1;
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
