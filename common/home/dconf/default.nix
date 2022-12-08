{ pkgs, lib, config, flakes, L, ... }:

{
	imports = [
		./gsconnect.nix
	];

	dconf.settings = let self = with lib.hm.gvariant; {
		"org/gnome/shell" = {
			welcome-dialog-last-shown-version = "99.0.0";

			enabled-extensions = mkArray type.string [
				"appindicatorsupport@rgcjonas.gmail.com"
				"gsconnect@andyholmes.github.io"
				"display-brightness-ddcutil@themightydeity.github.com"
			];
		};

		"org/gnome/shell/weather" = {
			automatic-location = true;
		};

		"org/gnome/desktop/interface" = {
			enable-animations = false;
		};

		"org/gnome/desktop/wm/preferences" = {
			focus-mode = "sloppy";
			resize-with-right-button = true;
		};

		"org/gnome/mutter" = {
			dynamic-workspaces = true;
		};

		"org/gnome/desktop/peripherals/mouse" = {
			accel-profile = "flat";
		};

		"org/gnome/settings-daemon/plugins/power" = {
			idle-dim = false;

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

		"org/gtk/gtk4/settings/file-chooser" = self."org/gtk/settings/file-chooser";

		"org/gnome/tweaks".show-extensions-notice = false;
		"ca/desrt/dconf-editor".show-warning = false;
	}; in self;
}

# vim: set ts=4 sw=4 noet :
