{ config, pkgs, lib, options, ... }:

{
	imports = [
		./hardware-configuration.nix
		./wayland.nix
		<home-manager/nixos>
		<musnix>
	];

	musnix.enable = true;

	boot = {
		kernelPackages = pkgs.linuxPackages_latest;

		loader = {
			systemd-boot.enable = true;
			efi = {
				canTouchEfiVariables = true;
				efiSysMountPoint = "/boot";
			};
		};

		plymouth.enable = true;
		# tmpOnTmpfs = true; # broken
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

		nameservers = [ "10.10.10.111" "10.10.10.1" "1.1.1.1" "1.0.0.1" ];

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

	time.timeZone = "America/Los_Angeles";

	environment.systemPackages = with pkgs; [
		zsh tmux neovim thefuck mosh minicom
		exa dfc ripgrep file pv units neofetch
		dnsutils speedtest-cli wget
		acpi usbutils pciutils lm_sensors efibootmgr multipath-tools
		linuxConsoleTools sdl-jstest
		zip unzip p7zip zstd xz
		ffmpeg imagemagick ghostscript
		piper

		firefox-devedition-bin transgui libreoffice
		mpv vlc rhythmbox
		gnome.gnome-sound-recorder gnome.gnome-tweaks
		virtmanager spice_gtk
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
				"scanner" "lp"
			];

			hashedPassword = "$6$o3HFaJySc0ptEcz$tr5ndkC9HMA0RDVobaLUncgzEiveeWtSJV8659EYdA2EnrNxB9vTrSmJVv5lAlF8nR0fu4HpBJ5e5wP02LHqq0";
			packages = with pkgs; [
				xclip xdotool
				libnotify pavucontrol youtube-dl powertop

				discord tdesktop element-desktop zoom-us
				blender kicad-with-packages3d prusa-slicer openscad
				google-play-music-desktop-player calibre
				gimp inkscape krita mtpaint aseprite-unfree
				kdenlive
				vcv-rack lmms
				# tilp gfm

				git gitAndTools.hub yadm gh
				gnupg1 nix-prefetch-github nix-prefetch-git
				adoptopenjdk-openj9-bin-15 ruby_3_0 bundix' pgmodeler
				python3 direnv arduino code-minimap
				hercules x3270

				qjackctl gcolor3 gst_all_1.gstreamer

				myWine winetricks lutris
				steam openarena multimc osu-lazer
				# rpcs3

				autokey bchunk espeak-ng
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

	systemd.services.transmission.serviceConfig.BindPaths = [ "/media/storage" ];

	services = {
		openssh.enable = true;
		printing.enable = true;
		gpm.enable = true;
		transmission = {
			enable = true;
			settings = {
				download-dir = "/media/storage/torrents";
				incomplete-dir = "/media/storage/torrents/incomplete";
				incomplete-dir-enabled = true;
				rpc-authentication-required = "true";
				rpc-username = "dmitry";
				rpc-password = (builtins.readFile ./transmission-password.txt);
				rpc-bind-address = "0.0.0.0";
				rpc-whitelist-enabled = false;
				peer-port = 25999;
			};
			port = 9091;
		};
		# Enable the X11 windowing system.
		xserver = {
			enable = true;
			layout = "us";
			desktopManager = {
				gnome.enable = true;
				xterm.enable = false;
			};
			displayManager = {
				defaultSession = "gnome";
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
			KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
			KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
			KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"
			SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE:="0666"
			KERNEL=="tun", GROUP="users", MODE="0660"
			${builtins.readFile "${pkgs.opentabletdriver}/lib/udev/rules.d/99-opentabletdriver.rules"}
		'';
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

		flatpak.enable = true;
		fwupd.enable = true;
		syncthing = {
			enable = true;
			user = "anna";
			dataDir = "/home/anna";
			configDir = "/home/anna/.config/syncthing";
		};

		atftpd.enable = true;
		vsftpd = {
			enable = true;
			localUsers = true;
			userlist = [ "anna" ];
			userlistEnable = true;
			chrootlocalUser = false;
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
			config.pipewire = {
				"default.clock.rate" = 96000;
			};
		};

		gpsd.enable = true;

		postgresql = {
			enable = true;
			package = pkgs.postgresql_13;
		};

		saned = {
			extraConfig = let
				firmware = pkgs.fetchurl {
					url = "https://github.com/stevleibelt/scansnap-firmware/raw/master/300_0C00.nal";
					hash = "sha256-C+279P7bRkZVYoV/+XGOTPKRYkbwal7bWWGSzq0wqg8=";
				}; in 
				''
					# Fujitsu S300
					firmware ${firmware}
					usb 0x04c5 0x1156
				'';
		};
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
		steam.enable = true;
		geary.enable = true;
	};

	environment.shellAliases = { ls = "exa"; };

	environment.variables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
		MOZ_ENABLE_WAYLAND = "true";
		SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
		QT_QPA_PLATFORM = "wayland";
		CALIBRE_USE_DARK_PALETTE = "1";
	};

	sound.enable = true;

	hardware = {
		pulseaudio.enable = false;
		trackpoint.enable = true;
		cpu.amd.updateMicrocode = true;
		bluetooth = {
			enable = true;
		};
		opengl = {
			enable = true;
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
			extraBackends = with pkgs; [ sane-airscan ];
		};
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
		pulseaudio = true;
		firefox = {
			enableGnomeExtensions = true;
		};

		permittedInsecurePackages = [
			"p7zip-16.02"
		];
		allowUnfree = true;
		allowBroken = true;
	};

	nixpkgs.overlays = [
		(self: super: {
			libbluray = super.libbluray.override {
				withAACS = true;
				withBDplus = true;
			};

			nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
				inherit pkgs;
			};

			myWine = (super.wineWowPackages.full.overrideAttrs (oa: {
				patches = [
					(super.fetchurl {
						url = "https://source.winehq.org/patches/data/197508";
						hash = "sha256-XPt6ArpIpYCx+HyHvy+H9qIxHMaoLvagBBsoGEuXcdE=";
					})
				];
			}));

			winetricks = super.winetricks.override { wine = self.myWine; };

			neovim-unwrapped = super.neovim-unwrapped.overrideAttrs (oa: {
				version = "0.5.0-dev";

				buildInputs = oa.buildInputs ++ [ super.tree-sitter ];

				src = super.fetchFromGitHub {
					owner = "neovim";
					repo = "neovim";
					rev = "17434b88b4892218386b49b400e7eb6d265000ff";
					hash = "sha256-xjXUlGsbqI2fp5ZfYNCwUBD4DZtw2zI/Bi82A4AV+hs=";
				};
			});

			transgui = super.transgui.overrideAttrs (oa: {
				 patches = [ ./0001-dedup-requestinfo-params.patch ];
			});

			bundler' = super.bundler.override { ruby = super.ruby_2_7; };
			bundix' = super.bundix.override { bundler = self.bundler'; };

			gnome = super.gnome.overrideScope' (gself: gsuper: {
				mutter = gsuper.mutter.overrideAttrs (oa: {
					patches = oa.patches ++ [
						./mutter-fix-tablet.patch
					];
				});
			});
		})
	];

	nix = {
		nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/etc/nixos/overlays-compat/" ];
		extraOptions = ''
			builders-use-substitutes = true
			secret-key-files = /etc/nix/cache.pem
			experimental-features = nix-command flakes ca-references
		'';
		package = pkgs.nixFlakes;
	};

	system.stateVersion = "18.09"; # Do not change unless specified in release notes
}
# vim: noet:ts=4:sw=4:ai:mouse=a
