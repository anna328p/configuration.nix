{ config, pkgs, lib, options, ... }:

{
	imports = [
		./hardware-configuration.nix
		(builtins.fetchurl "https://gist.github.com/peti/304a14130d562602c1ffa9128543bf38/raw/f651f7b1bc3cac130ed83f1ad5f3c1f2bcd9bf18/disable-gdm-auto-suspend.nix")
		<home-manager/nixos>
	];

	boot = {
		kernelPackages = pkgs.linuxPackages_latest;
		kernelParams = [ "iomem=relaxed" "pcie_aspm=off" ];
		kernelModules = [ "kvm-amd" "snd-seq" "snd-rawmidi" "nct6775" ];
		loader = {
			systemd-boot.enable = true;
			efi = {
				canTouchEfiVariables = true;
				efiSysMountPoint = "/boot";
			};
		};

		initrd = {
			availableKernelModules = [ "amdgpu" "vfio-pci" ];
			preDeviceCommands = ''
				DEVS="0000:0f:00.0 0000:0f:00.1" # 0000:03:00.0"
				for dev in $DEVS; do
					echo "vfio-pci" > /sys/bus/pci/devices/$dev/driver_override
				done
				modprobe -i vfio-pci
			'';
		};

		plymouth.enable = false;

		supportedFilesystems = [ "ntfs" "exfat" ];
	};

	networking = {
		hostName = "theseus";
		domain = "ad.dk0.us";

		networkmanager = {
			enable = true;
			dhcp = "dhclient";
			dns = "dnsmasq";
			packages = [ pkgs.dnsmasq ];
		};

		firewall.enable = false;

		nameservers = [ "104.248.109.126" "10.10.10.111" "10.10.10.1" "1.1.1.1" "1.0.0.1" ];

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
		acpi usbutils pciutils lm_sensors dmidecode nvtop efibootmgr multipath-tools
		linuxConsoleTools sdl-jstest
		zip unzip p7zip zstd xz
		ffmpeg imagemagick ghostscript

		nix gnupg1 nix-prefetch-github nix-prefetch-git
		adoptopenjdk-hotspot-bin-8 ruby_2_6 nodejs bundix binutils patchelf
		(python3.withPackages (p: with p; [ powerline ]))

		firefox-devedition-bin transgui
		gimp inkscape krita gimpPlugins.resynthesizer2 obs-studio
		libreoffice (gnome3.geary.overrideAttrs(_: { doCheck = false; }))
		mpv vlc rhythmbox gnome3.gnome-sound-recorder
		qjackctl gcolor2 gstreamer
		virtmanager spice_gtk
		# podman conmon runc slirp4netns fuse-overlayfs
	];
	environment.pathsToLink = [ "/share/zsh" ];

	fonts.fonts = with pkgs; [
		source-code-pro source-sans-pro source-serif-pro
		noto-fonts noto-fonts-cjk noto-fonts-emoji
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
			];

			hashedPassword = "$6$o3HFaJySc0ptEcz$tr5ndkC9HMA0RDVobaLUncgzEiveeWtSJV8659EYdA2EnrNxB9vTrSmJVv5lAlF8nR0fu4HpBJ5e5wP02LHqq0";
			packages = with pkgs; [
				xclip xautomation xdotool xfontsel catclock wmctrl
				termite maim slop libnotify pavucontrol youtube-dl powertop

				discord hexchat fractal weechat # tdesktop
				element-desktop
				zoom-us arduino
				blender kicad freecad prusa-slicer
				kdenlive
				google-play-music-desktop-player hercules x3270
				# tilp gfm

				wineWowPackages.unstable winetricks lutris
				steam minecraft cataclysm-dda openarena multimc minetest
				 rpcs3

				autokey bchunk espeak-ng
				vulkan-loader vulkan-tools

				piper

				direnv

				calibre
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
		transmission = {
			enable = true;
			settings = {
				download-dir = "/media/storage/torrents";
				ncomplete-dir = "/media/storage/torrents/incomplete";
				incomplete-dir-enabled = true;
				rpc-authentication-required = "true";
				rpc-username = "dmitry";
				rpc-password = (builtins.readFile ./transmission-password.txt);
				rpc-bind-address = "0.0.0.0";
				rpc-whitelist-enabled = false;
			};
			port = 9091;
		};
		# Enable the X11 windowing system.
		xserver = {
			enable = true;
			layout = "us";
			desktopManager = {
				gnome3.enable = true;
				xterm.enable = false;
			};
			displayManager = {
				defaultSession = "gnome-xorg";
				gdm = {
					enable = true;
					wayland = true;
				};
			};
			libinput.enable = true;
			wacom.enable = true;
		};
		udev.extraRules = ''
			# Steam Controller
			KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", TAG+="uaccess"
			SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
			KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
			KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
			KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"

			KERNEL=="tun", GROUP="users", MODE="0660"
		'';
		usbmuxd.enable = true;

		gnome3 = {
			chrome-gnome-shell.enable = true;
			#rygel.enable = true;
			evolution-data-server.enable = true;
			glib-networking.enable = true;
			gnome-user-share.enable = true;
			sushi.enable = true;
			tracker-miners.enable = true;
		};

		ratbagd.enable = true;

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

		pipewire.enable = true;

		flatpak.enable = true;
	};

	virtualisation = {
		libvirtd = {
			enable = true;
			qemuOvmf = true;
			qemuRunAsRoot = false;
			onShutdown = "shutdown";
		};
		docker.enable = true;
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

	environment.shellAliases = { ls = "exa"; };

	environment.variables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
		MOZ_ENABLE_WAYLAND = "true";
		SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
	};

	sound.enable = true;

	hardware = {
		# pulseaudio.enable = false;
		pulseaudio = {
			enable = true;
			support32Bit = true;
			extraModules = [ pkgs.pulseaudio-modules-bt ];
			package = pkgs.pulseaudioFull.override { jackaudioSupport = true; };
			daemon.config = {
				high-priority = "yes";
				nice-level = "-15";

				realtime-scheduling = "yes";
				realtime-priority = "50";

				resample-method = "speex-float-0";

				default-fragments = "2"; # Minimum is 2
				default-fragment-size-msec = "2"; # You can set this to 1, but that will break OBS audio capture.
			};

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
	};

	security = {
		sudo.wheelNeedsPassword = false;

		pam.loginLimits = [
			{ domain = "@audio"; type = "-"; item = "nice"; value = "-20"; }
			{ domain = "@audio"; type = "-"; item = "rtprio"; value = "99"; }
		];

		wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice_gtk}/bin/spice-client-glib-usb-acl-helper";
	};

	system = {
		autoUpgrade.enable = false;
	};

	nixpkgs.config = {
		allowUnfree = true;
		pulseaudio = true;
		firefox = {
			enableGnomeExtensions = true;
			enableAdobeFlash = true;
		};
		permittedInsecurePackages = [
			"p7zip-16.02"
		];
		allowBroken = true;
	};

	nixpkgs.overlays = [
		(self: super: {
			x3270 = super.callPackage ./x3270.nix {};

			libbluray = super.libbluray.override {
				withAACS = true;
				withBDplus = true;
			};

			nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
				inherit pkgs;
			};

			airwave = super.qt5.callPackage ./airwave.nix {};

			wine = super.wine.overrideAttrs (oldAttrs: {
				buildInputs = oldAttrs.buildInputs ++ [ super.libxml2 ];
			});
		})
	];
	nix.nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/etc/nixos/overlays-compat/" ];

	system.stateVersion = "18.09"; # Do not change unless specified in release notes
}
# vim: noet:ts=4:sw=4:ai:mouse=a
