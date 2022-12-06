{ pkgs, lib, flakes, ... }:

{
	imports = [
		./gnome.nix
		./witchhazel.nix
		./adwaita.nix
		./terminal.nix
		./firefox.nix
		./discord.nix
	];

	# for testing other themes:
	# colorScheme = flakes.nix-colors.colorSchemes.solarized-light;

	fonts.fontconfig.enable = true;

	misc.fonts = {
		ui = {
			package = pkgs.source-sans;
			name = "Source Sans 3";
			size = 10.8;
		};

		document = {
			package = pkgs.source-serif;
			name = "Source Serif 4";
			size = 10.8;
		};

		monospace = {
			package = pkgs.source-code-pro;
			name = "Source Code Pro";
			size = 11.8;
		};
	};

	gtk = {
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
