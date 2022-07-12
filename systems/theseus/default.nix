{ config, pkgs, lib, options, flakes, ... }:

{
	imports = [
		./hardware-configuration.nix
		flakes.musnix.nixosModule
	];

	boot = {
		kernelPackages = pkgs.linuxPackages_latest;

		kernelParams = [ "pcie_aspm=off" ];

		initrd.availableKernelModules = [
			"xhci_pci" "ehci_pci" "ahci" "nvme"
			"usb_storage" "usbhid" "uas" "sd_mod"
		];

		kernelModules = [ "nct6775" ];
	};

	hardware.nvidia = {
		prime.offload.enable = false;
		package = config.boot.kernelPackages.nvidiaPackages.beta;
	};

	musnix.enable = true;

	networking.hostName = "theseus";

	time.timeZone = "America/Los_Angeles";

	systemd.services.transmission.serviceConfig.BindPaths = [ "/media/storage" ];

	services = {
		transmission = {
			enable = true;

			settings = {
				rpc-port = 9091;
				rpc-bind-address = "0.0.0.0";
				rpc-whitelist-enabled = false;

				rpc-authentication-required = "true";
				rpc-username = "anna";
				rpc-password = (builtins.readFile ./transmission-password.txt);

				peer-port = 25999;

				download-dir = "/media/storage/torrents";
				incomplete-dir = "/media/storage/torrents/incomplete";
				incomplete-dir-enabled = true;
			};
		};

		atftpd.enable = true;

		vsftpd = {
			enable = true;
			localUsers = true;
			userlist = [ "anna" ];
			userlistEnable = true;
			chrootlocalUser = false;
		};

		gpsd.enable = true;

		xserver.deviceSection = ''
			Option "Coolbits" "31"
		'';

		xserver.displayManager.gdm = {
			autoSuspend = false;
			wayland = true;
		};
	};

	virtualisation = {
		libvirtd = {
			enable = true;
			onShutdown = "shutdown";

			qemu = {
				ovmf.enable = true;
				runAsRoot = false;
			};
		};

		podman.enable = true;
	};

	system.stateVersion = "18.09"; # Do not change unless specified in release notes
}
# vim: noet:ts=4:sw=4:ai:mouse=a
