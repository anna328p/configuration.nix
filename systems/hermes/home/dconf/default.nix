{ lib, ... }:

{
	imports = [
		./gsconnect.nix
	];

	dconf.settings = with lib.hm.gvariant; {
		"org/gnome/shell" = {
			welcome-dialog-last-shown-version = "99.0.0";

			enabled-extensions = mkArray type.string [
				"appindicatorsupport@rgcjonas.gmail.com"
				"gsconnect@andyholmes.github.io"
			];
		};

		"org/gnome/desktop/interface" = {
			font-name = "Source Sans 3 10.8";
			document-font-name = "Source Serif 4 10.8";
			monospace-font-name = "Source Code Pro 11.8";

			font-antialiasing = "rgba";
			font-hinting = "slight";

			color-scheme = "prefer-dark";
			gtk-theme = "Adwaita-dark";

			enable-animations = false;
		};

		"org/gnome/desktop/wm/preferences" = {
			focus-mode = "sloppy";
			resize-with-right-button = true;
			titlebar-font = "Source Sans 3 Bold 10.8";
		};

		"org/gnome/desktop/peripherals/mouse" = {
			accel-profile = "flat";
		};

		"org/gnome/settings-daemon/plugins/power" = {
			sleep-inactive-battery-type = "suspend";
			sleep-inactive-battery-timeout = 1800;

			sleep-inactive-ac-type = "nothing";
		};

		"org/gnome/settings-daemon/plugins/color" = {
			night-light-enabled = true;
		};

		"org/gnome/desktop/session" = {
			idle-delay = mkUint32 600;
		};

		"org/gnome/desktop/input-sources" = let
			inherit (lib.hm.gvariant.type) string tupleOf;

			mkStrPairArray = list:
				mkArray (tupleOf [string string]) (map mkTuple list);
		in {
			sources = mkStrPairArray [
				[ "xkb" "us" ]
				[ "xkb" "semimak-jq" ]
				[ "xkb" "semimak-jqa" ]
				[ "xkb" "ru" ]
				[ "ibus" "mozc-jp" ]
			];

			xkb-options = mkArray string [
				"terminate:ctrl_alt_bksp" "caps:escape"
			];
		};

		"org/gnome/nautilus/preferences" = {
			default-folder-viewer = "list-view";
			show-create-link = true;
			show-delete-permanently = true;
		};

		"org/gnome/nautilus/list-view" = {
			default-zoom-level = "small";
			use-tree-view = true;
		};

		"org/gtk/settings/file-chooser" = {
			sort-directories-first = true;
			sort-column = "modified";
			sort-order = "descending";
		};

		"ca/desrt/dconf-editor".show-warning = false;
	};
}

# vim: set ts=4 sw=4 noet :
