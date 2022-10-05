{ pkgs, config, ... }:

{
	programs.gnome-terminal = let
		scheme = config.colorScheme;
	in {
		enable = true;

		themeVariant = scheme.kind;

		profile.${scheme.slug} = {
			visibleName = scheme.name;
			default = true;

			colors = with scheme.colors; {
				backgroundColor = base00;
				foregroundColor = base04;

				cursor.background = base04;
				cursor.foreground = base01;

				highlight.background = base08;
				highlight.foreground = base00;

				palette = [
					base01 base0B base0E base0D base09 base0F base08 base05
					base03 base0B base0E base0D base09 base0F base07 base06
				];
			};
		};
	};
}
