{ pkgs, flakes, ... }:

{
	fonts.fontconfig.enable = true;

	gtk = {
		font = {
			package = pkgs.source-sans;
			name = "Source Sans 3 10.8";
		};
		theme.name = "Adwaita-dark";
	};

	qt = {
		enable = true;
		platformTheme = "gnome";
		style = {
			package = pkgs.adwaita-qt;
			name = "adwaita-dark";
		};
	};

	programs.dircolors = {
		enable = true;
		enableZshIntegration = true;

		extraConfig = (builtins.readFile files/dircolors);
	};

	colorScheme = flakes.nix-colors.colorSchemes.nord;
}

# vim: set ts=4 sw=4 noet :
