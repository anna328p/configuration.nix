{ config, pkgs, lib, options, ... }:

{
	imports = [
		./hardware-configuration.nix
	];

	boot = {
		kernelPackages = let
			main = pkgs.linuxPackages_latest;
			test = pkgs.linuxPackages_testing;
			kver = pkg: pkg.kernel.version;
			latest = if (kver main > kver test)
				then main
				else test;
		in builtins.trace (kver latest) latest;

		kernelParams = [ "iomem=relaxed" "iwlwifi.swcrypto=0" "bluetooth.disable_ertm=1" ];
		kernelModules = [ "kvm-amd" "snd-seq" "snd-rawmidi" "nct6775" "v4l2loopback" ];
		extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

		loader = {
			systemd-boot.enable = true;
			efi = {
				canTouchEfiVariables = true;
				efiSysMountPoint = "/boot";
			};
		};

		initrd.availableKernelModules = [ "amdgpu" ];

		supportedFilesystems = [ "ntfs" "exfat" ];
		
		plymouth.enable = true;
		tmpOnTmpfs = false;
	};

	networking = {
		hostName = "hermes";
		domain = "ad.dk0.us";

		networkmanager = {
			enable = true;
			dhcp = "dhclient";
			dns = "dnsmasq";
			packages = [ pkgs.dnsmasq ];
		};

		firewall.enable = false;

		enableIPv6 = true;
	};

	i18n = {
		defaultLocale = "en_US.UTF-8";
 		supportedLocales = [ "en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
 		inputMethod = {
 			enabled = "ibus";
 			ibus.engines = with pkgs.ibus-engines; [ mozc ];
 		};
	};

	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
	};

	time.timeZone = "America/Chicago";

	environment.systemPackages = with pkgs; [
		zsh tmux neovim mosh lftp
		exa dfc ripgrep file pv units neofetch
		dnsutils speedtest-cli wget
		git gitAndTools.hub
		acpi usbutils pciutils lm_sensors efibootmgr multipath-tools powertop
		linuxConsoleTools sdl-jstest piper
		zip unzip _7zz zstd xz
		ffmpeg imagemagick ghostscript

		firefox-devedition-bin transgui libreoffice
		mpv vlc rhythmbox gnome.gnome-sound-recorder
		virtmanager spice_gtk

		gnomeExtensions.gsconnect
	];
	environment.pathsToLink = [ "/share/zsh" ];

	fonts.fonts = with pkgs; [
		source-code-pro source-sans-pro source-serif-pro
		noto-fonts noto-fonts-cjk noto-fonts-emoji-blob-bin
		liberation_ttf
	];

	users = {
		mutableUsers = false;
		defaultUserShell = pkgs.zsh;

		users.anna = {
			description = "Anna";
			isNormalUser = true;
			uid = 1000;

			subUidRanges = [ { startUid = 100000; count = 9999; } ];
			subGidRanges = [ { startGid = 10000; count = 999; } ];

			extraGroups = [
				"wheel" "networkmanager" "dialout" "transmission" "audio"
				"vboxusers" "adbusers" "libvirtd" "jackaudio" "docker"
				"scanner" "lp"
			];

			hashedPassword = "$6$o3HFaJySc0ptEcz$tr5ndkC9HMA0RDVobaLUncgzEiveeWtSJV8659EYdA2EnrNxB9vTrSmJVv5lAlF8nR0fu4HpBJ5e5wP02LHqq0";
			packages = with pkgs; [
				xclip xdotool
				libnotify pavucontrol youtube-dl powertop

				discord discord-canary tdesktop element-desktop zoom-us
				blender prusa-slicer
				kicad-with-packages3d
				ytmdesktop
				gimp inkscape krita aseprite-unfree kdenlive

				git gh gnupg1
				nix-prefetch-github nix-prefetch-git bundix cachix direnv
				adoptopenjdk-openj9-bin-16 ruby_3_0 python3 arduino go

				iotop strace appimage-run pigz woeusb

				qjackctl gcolor2

				myWine winetricks lutris
				steam steam-run multimc wesnoth

				bchunk espeak-ng calibre
				opensc pcsctools
				anki
				plover.dev
			];
		};

		users.root = {
			hashedPassword = "$6$NxlrJrFQmV$NP4yc0wyb8LuYKApfAYpo52iorA5gDF44NmQUS21fkxVyW.PeLO14xow2l1Sa35LuwDPenQIgsD08xbCqjSgH.";
		};
	};

	services = {
		openssh.enable = true;
		printing = {
			enable = true;
			drivers = with pkgs; [ brlaser brgenml1cupswrapper ];
		};
		gpm.enable = true;

		xserver = {
			enable = true;
			layout = "us";

			desktopManager = {
				gnome.enable = true;
				xterm.enable = false;
			};

			displayManager.gdm = {
				enable = true;
				wayland = true;
			};

			libinput.enable = true;
			wacom.enable = true;

			videoDrivers = [ "amdgpu" ];
			deviceSection = ''
				Option "VariableRefresh" "true"
				Option "TearFree" "true"
			'';
		};

		udev = {
			extraRules = ''
				# Steam Controller
				KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", TAG+="uaccess"
				SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
				SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", MODE="0666"
				KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
				KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
				KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"

				# GameCube Controller Adapter
				SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
				SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b672", MODE="0666"

				KERNEL=="tun", GROUP="users", MODE="0666"

				# TI
				ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e001", MODE="0666", GROUP="plugdev"
				ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e003", MODE="0666", GROUP="plugdev"
				ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e004", MODE="0666", GROUP="plugdev"
				ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e008", MODE="0666", GROUP="plugdev"
				ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e012", MODE="0666", GROUP="plugdev"
				KERNEL=="tun", GROUP="users", MODE="0660"

				# ADALM2000
				ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0456", ATTR{idProduct}=="b672", MODE="0666", group="plugdev"
			'' + builtins.readFile (builtins.fetchurl {
				url = "https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules";
				sha256 = "0whfqh0m3ps7l9w00s8l6yy0jkjkssqnsk2kknm497p21cs43wnm";
			});

			packages = with pkgs; [ gnome.gnome-settings-daemon ];
		};

		usbmuxd.enable = true;

		gnome = {
			chrome-gnome-shell.enable = true;
			rygel.enable = false;
			evolution-data-server.enable = true;
			glib-networking.enable = true;
			gnome-user-share.enable = true;
			sushi.enable = true;
			tracker.enable = true;
			tracker-miners.enable = true;
			games.enable = true;
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

		flatpak.enable = true;
		#fprintd.enable = true; # broken
		fwupd.enable = true;
		fstrim.enable = true;
		syncthing = {
			enable = true;
			user = "anna";
			dataDir = "/home/anna";
			configDir = "/home/anna/.config/syncthing";
		};

		pipewire = {
			enable = true;
			pulse.enable = true;
			alsa = {
				enable = true;
				support32Bit = true;
			};
			jack.enable = true;
			media-session.enable = true;
		};
		postgresql = {
			enable = true;
			package = pkgs.postgresql_13;
		};
		ratbagd.enable = true;
		pcscd.enable = true;

		zerotierone = {
			enable = true;
			joinNetworks = [ "abfd31bd4777d83c" ];
		};
	};

	virtualisation = {
		libvirtd.enable = true;
	};

	programs = {
		zsh = {
			enable = true;
			promptInit = "";
		};
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
	};

	environment.variables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
		MOZ_ENABLE_WAYLAND = "true";
		SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
		QT_QPA_PLATFORM = "wayland";
	};

	sound.enable = true;

	hardware = {
		pulseaudio.enable = false;
		bluetooth.enable = true;
		trackpoint.enable = true;

		cpu.amd.updateMicrocode = true;

		opengl = {
			driSupport32Bit = true;
			extraPackages = with pkgs; [
				libva1-full
				vaapiVdpau
				libvdpau-va-gl
				vulkan-tools
			];
		};

		sane = {
			enable = true;
			extraBackends = with pkgs; [
				sane-airscan
				hplipWithPlugin
			];
		};
	};

	security = {
		sudo.wheelNeedsPassword = false;

		pam.loginLimits = [
			{ domain = "@audio"; type = "-"; item = "nice"; value = "-20"; }
			{ domain = "@audio"; type = "-"; item = "rtprio"; value = "99"; }
		];

		rtkit.enable = true;
	};

	system.autoUpgrade.enable = false;

	nixpkgs.config = {
		allowUnfree = true;
		allowBroken = true;
		pulseaudio = true;
		firefox.enableGnomeExtensions = true;
	};

	nixpkgs.overlays = [
		(self: super: {
			transgui = super.transgui.overrideAttrs (oldAttrs: {
				patches = [ ./0001-dedup-requestinfo-params.patch ];
			});

			myWine = super.wineWowPackages.full.override {
				wineRelease = "staging";
				gtkSupport = true;
				vaSupport = true;
			};

			winetricks = super.winetricks.override { wine = self.myWine; };

			rhythmbox = super.rhythmbox.overrideAttrs (oa: rec {
				p3 = super.python3.withPackages (p: with p; [ pygobject3 ]);

				nativeBuildInputs = oa.nativeBuildInputs ++ (with super; [
					python38Packages.pygobject3.dev
				]);

				buildInputs = with super; [
					p3 (libpeas.override { python3 = p3; })
					libsoup tdb json-glib gtk3 totem-pl-parser
					gnome.adwaita-icon-theme

					libgudev libgpod libmtp libnotify brasero grilo grilo-plugins
				] ++ (with super.gst_all_1; [
					gstreamer gst-plugins-base gst-plugins-good gst-plugins-ugly
				]);

				preFixup = ''
					gappsWrapperArgs+=(--prefix PATH : "${p3}/bin")
				'';

				configureFlags = [ "--enable-python" ];
			});

			calibre = super.calibre.overrideAttrs (oa: {
				buildInputs = oa.buildInputs ++ [ super.python3Packages.pycryptodome ];
			});
		})

		(import (builtins.fetchGit {
			url = "https://github.com/anna328p/tilp-nix";
			rev = "8767c1911ec8e0cfe3801383c1438cedb767c710";
		}))
	];

	nix = {
		nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/etc/nixos/overlays-compat/" ];
		extraOptions = ''
			experimental-features = nix-command flakes ca-references ca-derivations
		'';
		package = pkgs.nixFlakes;
	};

	system.stateVersion = "20.09"; # Do not change unless specified in release notes
}
# vim: noet:ts=4:sw=4:ai:mouse=a
