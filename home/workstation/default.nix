{ flakes, lib, ... }:

{
	imports = [
		flakes.nix-colors.homeManagerModule

		./shell.nix
		./ssh.nix
		./git.nix
		./editor.nix

		./dconf
		./theming

		./transgui.nix
	];

	home = {
		sessionVariables = {
			NIX_AUTO_RUN = 1;
			MOZ_USE_XINPUT2 = 1;
		};
	};

	xdg = {
		enable = true;
		userDirs.enable = true;
	};

	services.fluidsynth.enable = true;

	programs.obs-studio.enable = true;

	manual.manpages.enable = lib.mkForce true;
}
