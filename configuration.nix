{ config, pkgs, lib, options, ... }:

{
	imports = [
		./hardware-configuration.nix
		<home-manager/nixos>
	];

	boot = {
		kernelPackages = pkgs.linuxPackages_testing;
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

		initrd = {
			availableKernelModules = [ "amdgpu" ];
		};

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

		nameservers = [ "10.10.10.1" "1.1.1.1" "1.0.0.1" ];

		enableIPv6 = true;
	};

	i18n = {
		defaultLocale = "en_US.UTF-8";
	};

	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
	};

	time.timeZone = "America/Los_Angeles";

	environment.systemPackages = with pkgs; [
		zsh tmux neovim thefuck hexedit mosh minicom lftp
		exa dfc ripgrep file pv units neofetch dnsutils ldns speedtest-cli wget
		git gitAndTools.hub yadm
		acpi usbutils pciutils lm_sensors dmidecode efibootmgr multipath-tools powertop
		linuxConsoleTools sdl-jstest
		zip unzip p7zip zstd xz
		ffmpeg imagemagick ghostscript
		xxd

		nix gnupg1 nix-prefetch-github nix-prefetch-git
		adoptopenjdk-hotspot-bin-8 ruby_2_7 nodejs bundix binutils patchelf
		solargraph

		firefox-devedition-bin transgui
		gimp inkscape krita
		obs-studio obs-v4l2sink
		libreoffice gnome3.geary
		mpv vlc rhythmbox gnome3.gnome-sound-recorder
		virtmanager spice_gtk
		# podman conmon runc slirp4netns fuse-overlayfs

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
				xclip xautomation xdotool xfontsel catclock wmctrl
				maim slop libnotify pavucontrol youtube-dl

				discord hexchat weechat element-desktop tdesktop
				zoom-us arduino
				blender kicad prusa-slicer # freecad
				kdenlive
				google-play-music-desktop-player
				tilp gfm

				wineWowPackages.staging winetricks
				steam retroarch libretro.vba-next libretro.bsnes-mercury
				openarena osu-lazer multimc

				bchunk espeak-ng
				carla

				piper
				direnv
				# calibre
			];
		};
		users.root = {
			hashedPassword = "$6$NxlrJrFQmV$NP4yc0wyb8LuYKApfAYpo52iorA5gDF44NmQUS21fkxVyW.PeLO14xow2l1Sa35LuwDPenQIgsD08xbCqjSgH.";
		};
	};

	home-manager = {
		users.anna = (import ./home.nix);
		useUserPackages = true;
		useGlobalPkgs = true;
	};

	services = {
		openssh.enable = true;
		printing.enable = true;
		gpm.enable = true;
		xserver = {
			enable = true;
			layout = "us";
			desktopManager = {
				gnome3.enable = true;
				xterm.enable = false;
			};
			displayManager = {
				# defaultSession = "gnome-xorg";
				gdm = {
					enable = true;
					wayland = true;
				};
			};
			libinput.enable = true;
			wacom.enable = true;
			videoDrivers = [ "amdgpu" ];
			deviceSection = ''
				Option "VariableRefresh" "true"
				Option "TearFree" "true"
			'';
		};
		udev.extraRules = ''
			# Steam Controller
			KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", TAG+="uaccess"
			SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
			SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", MODE="0666"
			KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
			KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
			KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"

			SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
			SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b672", MODE="0666"

			KERNEL=="tun", GROUP="users", MODE="0666"

			# TI
			ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e001", MODE="0666", GROUP="plugdev"
			ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e003", MODE="0666", GROUP="plugdev"
			ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e004", MODE="0666", GROUP="plugdev"
			ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e008", MODE="0666", GROUP="plugdev"
			ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e012", MODE="0666", GROUP="plugdev"
		'' + builtins.readFile (builtins.fetchurl {
			url = "https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules";
			sha256 = "0whfqh0m3ps7l9w00s8l6yy0jkjkssqnsk2kknm497p21cs43wnm";
		});

		usbmuxd.enable = true;

		gnome3 = {
			chrome-gnome-shell.enable = true;
			evolution-data-server.enable = true;
			glib-networking.enable = true;
			gnome-user-share.enable = true;
			sushi.enable = true;
			tracker-miners.enable = true;
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
		# fprintd.enable = true; # broken
		fwupd.enable = true;
		tlp.enable = true;
		fstrim.enable = true;
		syncthing = {
			enable = true;
			user = "anna";
			dataDir = "/home/anna";
			configDir = "/home/anna/.config/syncthing";
		};

		pipewire.enable = true;
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
	};

	environment.variables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
		MOZ_ENABLE_WAYLAND = "true";
		SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
	};

	sound.enable = true;

	hardware = {
		pulseaudio = {
			enable = true;
			support32Bit = true;
			extraModules = [ pkgs.pulseaudio-modules-bt ];

			extraConfig = ''
				load-module module-udev-detect tsched=1
			'';
		};
		trackpoint.enable = true;
		cpu.amd.updateMicrocode = true;
		bluetooth = {
			enable = true;
		};
		opengl.driSupport32Bit = true;
		nvidia.modesetting.enable = true;
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

		wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice_gtk}/bin/spice-client-glib-usb-acl-helper";

		rtkit.enable = true;
	};

	system = {
		autoUpgrade.enable = false;
	};

	nixpkgs.config = {
		allowUnfree = true;
		pulseaudio = true;
		firefox = {
			enableGnomeExtensions = true;
			# enableAdobeFlash = true; # broken most of the time
		};
		permittedInsecurePackages = [
			"p7zip-16.02"
		];
		allowBroken = true;
		retroarch = {
			enableVbaNext = true;
			enableBsnesMercury = true;
		};
	};

	nixpkgs.overlays = [
		(self: super: {
			nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
				inherit pkgs;
			};

			gjs = super.gjs.overrideAttrs (oldAttrs: { doCheck = false; });

			transgui = super.transgui.overrideAttrs (oldAttrs: {
				patches = [
					./0001-dedup-requestinfo-params.patch
				];
			});
		})

		(import (builtins.fetchGit {
			url = "https://github.com/anna328p/tilp-nix";
			rev = "8767c1911ec8e0cfe3801383c1438cedb767c710";
		}))
	];
	nix.nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/etc/nixos/overlays-compat/" ];

	system.stateVersion = "20.09"; # Do not change unless specified in release notes
}
# vim: noet:ts=4:sw=4:ai:mouse=a
