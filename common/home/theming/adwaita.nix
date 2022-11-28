{ lib, config, ... }:

let
	defs = let
		formatted = lib.mapAttrs (_: v: "#${v}") config.colorScheme.colors;
	in with formatted; rec {
		accent_color    = base0C;
		accent_bg_color = accent_color;
		accent_fg_color = base05;

		destructive_color    = base08;
		destructive_bg_color = destructive_color;
		destructive_fg_color = base05;

		success_color    = base0B;
		success_bg_color = success_color;
		success_fg_color = base05;

		warning_color    = base0A;
		warning_bg_color = warning_color;
		warning_fg_color = base05;

		error_color    = destructive_color;
		error_bg_color = error_color;
		error_fg_color = base05;

		window_bg_color = base00;
		window_fg_color = base05;

		view_bg_color = base01;
		view_fg_color = base05;

		headerbar_bg_color = base01;
		headerbar_fg_color = base05;
		headerbar_border_color = base04;
		headerbar_backdrop_color = base00;

		card_bg_color = base01;
		card_fg_color = base05;

		dialog_bg_color = base01;
		dialog_fg_color = base05;

		popover_bg_color = base01;
		popover_fg_color = base05;
	};

	css' = builtins.concatStringsSep "\n"
		(lib.mapAttrsToList
			(name: val: "@define-color ${name} ${val};")
			defs);
	
	css = ''
		${css'}
	'';
in {
	xdg.configFile = {
		"gtk-3.0/gtk.css".text = css;
		"gtk-4.0/gtk.css".text = css;
	};
}
