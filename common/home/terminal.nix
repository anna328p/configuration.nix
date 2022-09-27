{ pkgs, ... }:

{
	programs.kitty = {
		enable = true;
		theme = "Nord";

		font = {
			package = pkgs.hasklig;
			name = "Hasklig";
		};

		extraConfig = ''
			font_size 11.8
			cursor none
			scrollback_lines 0

			wayland_titlebar_color system
		'';
	};
}
