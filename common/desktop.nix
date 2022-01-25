{ config, pkgs, lib, ... }:

{
	boot = {
		plymouth.enable = true;
		supportedFilesystems = [ "ntfs" "exfat" ];

		kernelModules = [ "i2c-dev" "v4l2loopback" ];
		extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
	};

	networking = {
		networkmanager = {
			enable = true;
			dhcp = "dhclient";
			dns = "dnsmasq";
			packages = [ pkgs.dnsmasq ];
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

	environment.systemPackages = with pkgs; [
		nmap dnsutils mosh
		mullvad-vpn
		piper
		ffmpeg imagemagick

		ddcutil xclip

		firefox-devedition-bin transgui libreoffice
		discord tdesktop
		mpv vlc gnome.gnome-sound-recorder gnome.gnome-tweaks
		helvum
		virtmanager spice_gtk
		espeak-ng 

		gnomeExtensions.gsconnect
		gnomeExtensions.brightness-control-using-ddcutil
	];

	fonts.fonts = with pkgs; [
		source-code-pro source-sans-pro source-serif-pro
		noto-fonts noto-fonts-cjk noto-fonts-emoji-blob-bin
		liberation_ttf
	];

	home-manager = {
		users.anna = import ./home;

		useUserPackages = true;
		useGlobalPkgs = true;

		extraSpecialArgs = { inherit (pkgs) neovim; };
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
			prusa-slicer openscad solvespace
			kicad-with-packages3d
			mpdris2
			gimp inkscape krita

			gh gnupg1 nodejs
			nix-prefetch-git cachix direnv
			nixpkgs-review
			adoptopenjdk-openj9-bin-16 ruby_3_0 python3 mono
			jq

			appimage-run

			gcolor3

			myWine winetricks
			steam steam-run polymc sidequest

			calibre
			anki
			plover.dev

			fd osu-lazer freemind guvcview ydotool
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
			};
		};

		gnome = {
			glib-networking.enable = true;
			sushi.enable = true;
			experimental-features.realtime-scheduling = true;
		};

		avahi = {
			enable = true;
			ipv6 = true;
			reflector = true;
			publish = {
				enable = true;
				userServices = true;
				addresses = true;
				hinfo = true;
				workstation = true;
				domain = true;
			};
			nssmdns = true;
		};

		zerotierone = {
			enable = true;
			joinNetworks = [
				"abfd31bd4777d83c" # annanet
				"abfd31bd479dc978" # linda
				"565799d8f678b97f" # mcserver
			];
		};

		mullvad-vpn.enable = true;

		usbmuxd.enable = true;
		ratbagd.enable = true;
		flatpak.enable = true;
		fstrim.enable = true;

		syncthing = {
			enable = true;
			user = "anna";
			dataDir = "/home/anna";
			configDir = "/home/anna/.config/syncthing";
		};

		udev = import ./udev.nix { inherit pkgs; };

		pipewire = {
			enable = true;
			pulse.enable = true;
			jack.enable = true;
			media-session.enable = true;

			alsa = {
				enable = true;
				support32Bit = true;
			};

			config.pipewire = {
				"context.properties.default.clock" = {
					quantum = 32;
					min-quantum = 32;
					max-quantum = 8192;
				};
			};

			config.pipewire-pulse = {
				"context.modules" = [
					{ name = "libpipewire-module-rtkit";
					  flags = [ "ifexists" "nofail" ]; }
					{ name = "libpipewire-module-protocol-native"; }
					{ name = "libpipewire-module-client-node"; }
					{ name = "libpipewire-module-adapter"; }
					{ name = "libpipewire-module-metadata"; }
					{ name = "libpipewire-module-protocol-pulse";
					  args = { "server.address" = [ "unix:native" "tcp:4713" ];
				               "vm.overrides" = { "pulse.min.quantum" = "1024/48000"; }; }; }
				];
			};
		};
	};

	systemd.user.services.mpdris2 = {
		description = "MPRIS2 support for MPD";
		serviceConfig = {
			Type = "simple";
			Restart = "on-failure";
			ExecStart = "${pkgs.mpdris2}/bin/mpDris2";
		};
	};

	programs = {
		zsh.promptInit = "";

		gnupg.agent = {
			enable = true;
			enableSSHSupport = true;
		};

		adb.enable = true;
		steam.enable = true;

		kdeconnect = {
			enable = true;
			package = pkgs.gnomeExtensions.gsconnect;
		};
	};

	environment.variables = {
		MOZ_ENABLE_WAYLAND = "1";
		SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
		QT_QPA_PLATFORM = "wayland";
	};

	sound.enable = true;

	hardware = {
		pulseaudio.enable = false;
		bluetooth.enable = true;

		opengl.extraPackages = with pkgs; [ libva1-full vaapiVdpau libvdpau-va-gl vulkan-tools ];

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