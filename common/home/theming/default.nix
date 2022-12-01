{ pkgs, lib, flakes, ... }:

{
	imports = [
		./witchhazel.nix
		./adwaita.nix
		./terminal.nix
		./firefox.nix
		./discord.nix
	];

	# for testing other themes:
	# colorScheme = flakes.nix-colors.colorSchemes.solarized-light;

	fonts.fontconfig.enable = true;

	gtk = {
		font = {
			package = pkgs.source-sans;
			name = "Source Sans 3";
			size = 11;
		};

		theme = {
			package = pkgs.adw-gtk3;
			name = "adw-gtk3-dark";
		};
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

		extraConfig = (builtins.readFile ./dircolors);
	};
}

# vim: set ts=4 sw=4 noet :
