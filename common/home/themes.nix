{ pkgs, ... }:

{
	fonts.fontconfig.enable = true;

	gtk = {
		font = {
			package = pkgs.source-sans-pro;
			name = "Source Sans Pro 11";
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
}

# vim: set ts=4 sw=4 noet :
