{ pkgs, pkgsMaster, lib, ... }:

{
	# IME support
	i18n = {
 		supportedLocales = [ "en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
 		inputMethod = {
 			enabled = "ibus";
 			ibus.engines = with pkgs.ibus-engines; [ mozc ];
 		};
	};

	environment.systemPackages = with pkgs; [
		# Clipboard management
		xclip

		# Automation
		ydotool

		# Color picker
		gcolor3

		# GNOME addons
		gnome.gnome-sound-recorder gnome.gnome-tweaks

		# GTK theme
		adw-gtk3
	] ++ (with pkgsMaster.gnomeExtensions; [
		gsconnect
		brightness-control-using-ddcutil
		sensory-perception
		compiz-windows-effect
		appindicator
	]);

	environment.variables = {
		# Force Wayland support
		MOZ_USE_XINPUT2 = "1";
		MOZ_ENABLE_WAYLAND = "1";
		QT_QPA_PLATFORM = "wayland";

		# Misc

		CALIBRE_USE_DARK_PALETTE = "1";

		SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
	};

	# System fonts
	fonts = {
		enableDefaultFonts = true;

		fonts = with pkgs; [
			source-code-pro source-sans source-serif
			noto-fonts noto-fonts-cjk noto-fonts-emoji-blob-bin
			liberation_ttf open-sans corefonts

			# google-fonts # builder broken?
		];
	};

	environment.gnome.excludePackages = with pkgs; [
		gnome-connections # TODO: re-enable. freerdp fails to build due to winpr2 dep not found
	];

	services = {
		xserver = {
			enable = true;
			layout = "us";

			desktopManager = {
				xterm.enable = false;

				gnome = {
					enable = true;

					# Declaratively configure dash
					favoriteAppsOverride = let
						genList = lib.concatMapStringsSep ", " (s: "'${s}.desktop'");

						overrideList = names: ''
							[org.gnome.shell]
							favorite-apps=[ ${genList names} ]
						'';
					in overrideList [
						"firefox" "discord" "telegramdesktop"
						"org.gnome.Nautilus" "org.gnome.Terminal"
					];
				};
			};

			displayManager.gdm = {
				enable = true;
				wayland = true;
			};

			libinput.enable = true;
			wacom.enable = true;

			extraLayouts = {
				semimak-jq = {
					description = "English (Semimak JQ)";
					languages = [ "eng" ];
					symbolsFile = files/symbols/semimak-jq;
				};

				semimak-jqa = {
					description = "English (Semimak JQa)";
					languages = [ "eng" ];
					symbolsFile = files/symbols/semimak-jqa;
				};

				canary = {
					description = "English (Canary)";
					languages = [ "eng" ];
					symbolsFile = files/symbols/canary;
				};
			};
		};

		gnome.core-developer-tools.enable = true;
		gnome.gnome-remote-desktop.enable = false; # # TODO: re-enable. freerdp fails to build
	};

	programs = {
		# Mobile syncing
		kdeconnect = {
			enable = true;
			package = pkgs.gnomeExtensions.gsconnect;
		};

		# Email client
		geary.enable = true;

		gnome-terminal.enable = true;
	};


	# Allow using extensions.gnome.org in firefox
	nixpkgs.config = {
		firefox.enableGnomeExtensions = true;
	};
}
