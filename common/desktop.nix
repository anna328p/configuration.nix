{ config, pkgs, pkgsMaster, lib, specialArgs, ... }:

{
	imports = [
		./pipewire.nix
		./udev.nix
	];

	boot = {
		plymouth.enable = true;
		supportedFilesystems = [ "ntfs" "exfat" ];

		kernelParams = [ "iomem=relaxed" ];

		kernelModules = [ "i2c-dev" "v4l2loopback" "snd-seq" "snd-rawmidi" "ddcci" ];
		extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ddcci-driver ];
	};

	networking = {
		networkmanager = {
			enable = true;
			wifi.backend = "iwd";
		};

		firewall.enable = false;
	};

	i18n = {
 		supportedLocales = [ "en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
 		inputMethod = {
 			enabled = "ibus";
 			ibus.engines = with pkgs.ibus-engines; [ mozc ];
 		};
	};

	environment.systemPackages = with pkgs; let
		discord' = pkgs.symlinkJoin {
			name = "discord-wrapped";
			paths = [ (pkgsMaster.discord.override { withOpenASAR = true; }) ];
			buildInputs = [ pkgs.makeWrapper ];
			postBuild = ''
				wrapProgram $out/bin/Discord \
				--add-flags "--disable-smooth-scrolling"
			'';
		};
	in [
		nmap dnsutils mosh
		mullvad-vpn
		piper
		ffmpeg imagemagick

		ddcutil xclip

		firefox-devedition-bin transgui libreoffice
		tdesktop discord' element-desktop
		mpv vlc gnome.gnome-sound-recorder gnome.gnome-tweaks
		helvum #vcv-rack
		# virtmanager spice-gtk
		espeak-ng 

	] ++ (with pkgs.gnomeExtensions; [
		gsconnect
		brightness-control-using-ddcutil
		sensory-perception
		compiz-windows-effect
		appindicator
	]);

	environment.variables = {
		MOZ_USE_XINPUT2 = "1";
		# MOZ_ENABLE_WAYLAND = "1"; # currently breaks windowing

		QT_QPA_PLATFORM = "wayland";

		CALIBRE_USE_DARK_PALETTE = "1";

		SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
	};

	fonts = {
		enableDefaultFonts = true;

		fonts = with pkgs; [
			source-code-pro source-sans source-serif
			noto-fonts noto-fonts-cjk noto-fonts-emoji-blob-bin
			liberation_ttf open-sans corefonts

			google-fonts
		];
	};

	home-manager = {
		users.anna = import ./home;

		useUserPackages = true;
		useGlobalPkgs = true;

		extraSpecialArgs = specialArgs;
	};

	users.groups.i2c = {};

	users.users.anna = {
		extraGroups = [
			"networkmanager" "dialout" "audio" "video" "adbusers"
			"jackaudio" "scanner" "lp" "i2c"
		];
		
		packages = with pkgs; [
			pavucontrol

			zoom-us
			# prusa-slicer # broken
			openscad solvespace
			# kicad-with-packages3d # broken
			mpdris2

			gimp inkscape krita
			kdenlive audacity guvcview 

			nixpkgs-review nix-prefetch-git cachix
			direnv

			gh gnupg1 nodejs jq fd
			adoptopenjdk-openj9-bin-16 ruby_3_1 python3 mono
			cabal-install cabal2nix ghc

			appimage-run

			gcolor3 ydotool

			myWine winetricks protontricks

			steam steam-run polymc sidequest osu-lazer

			calibre
			# anki
			plover.dev

			fontforge-gtk nodePackages.svgo
		];
	};

	services = {
		mopidy = {
			# enable = true; # broken
			extensionPackages = with pkgs; [
				mopidy-mpd mopidy-iris mopidy-scrobbler
				mopidy-ytmusic mopidy-somafm
			];

			configuration = builtins.readFile files/mopidy.conf;
		};

		printing = {
			enable = true;
			drivers = with pkgs; [ brlaser brgenml1cupswrapper ];
		};

		xserver = {
			enable = true;
			layout = "us";

			desktopManager = {
				xterm.enable = false;

				gnome = {
					enable = true;

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

		gnome = {
			glib-networking.enable = true;
			sushi.enable = true;
		};

		avahi = {
			enable = true;
			ipv6 = true;
			nssmdns = true;
		};

		mullvad-vpn.enable = true;

		zerotierone = {
			enable = true;
			joinNetworks = [
				"abfd31bd4777d83c" # annanet
				"abfd31bd479dc978" # linda
				"565799d8f678b97f" # mcserver
			];
		};

		syncthing = {
			enable = true;
			user = "anna";
			dataDir = "/home/anna";
			configDir = "/home/anna/.config/syncthing";
		};

		flatpak.enable = true;

		usbmuxd.enable = true;
		ratbagd.enable = true;
		fstrim.enable = true;
		fwupd.enable = true;
	};

	systemd.user.services.mpdris2 = {
		description = "MPRIS2 support for MPD";
		serviceConfig = {
			Type = "simple";
			Restart = "on-failure";
			ExecStart = "${pkgs.mpdris2}/bin/mpDris2";
		};
	};

	systemd.services.NetworkManager-wait-online.enable = false;

	programs = {
		zsh.promptInit = "";

		gnupg.agent = {
			enable = true;
			enableSSHSupport = true;
		};

		adb.enable = true;
		steam.enable = true;
		geary.enable = true;

		kdeconnect = {
			enable = true;
			package = pkgs.gnomeExtensions.gsconnect;
		};
		
		gnome-terminal.enable = true;
	};

	sound.enable = true;

	hardware = {
		pulseaudio.enable = false;
		bluetooth.enable = true;

		opengl.extraPackages = with pkgs; [ libva1 vaapiVdpau libvdpau-va-gl ];

		sane = {
			enable = true;
			extraBackends = with pkgs; [ sane-airscan ];
		};
	};

	security = {
		pam.loginLimits = [
			{ domain = "@audio"; type = "-"; item = "nice"; value = "-20"; }
			{ domain = "@audio"; type = "-"; item = "rtprio"; value = "99"; }
		];

		rtkit.enable = true;
	};

	system.autoUpgrade.enable = false;

	nixpkgs.config = {
		pulseaudio = true;
		firefox.enableGnomeExtensions = true;
	};
}
# vim: noet:ts=4:sw=4:ai:mouse=a
