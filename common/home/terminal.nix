{ pkgs, lib, config, ... }:

{
	programs.gnome-terminal = let
		scheme = config.colorScheme;
		profileUUID = "7dc9e410-f2aa-47f5-9bf1-e65d55f704a9"; # uuidgen

		colorsPrefixed = lib.mapAttrs (_: val: "#${val}") scheme.colors;
	in {
		enable = true;

		themeVariant = scheme.kind;

		profile.${profileUUID} = {
			visibleName = scheme.name;
			default = true;

			showScrollbar = false;

			colors = with colorsPrefixed; {
				backgroundColor = base00;
				foregroundColor = base04;

				cursor.background = base04;
				cursor.foreground = base01;

				highlight.background = base08;
				highlight.foreground = base00;

				palette = [
					base01 base08 base0B base0A base0D base0E base0C base05
					base03 base08 base0B base0A base0D base0E base07 base06
				];
			};
		};
	};
}
