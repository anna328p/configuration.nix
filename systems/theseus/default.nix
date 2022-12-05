{ config, pkgs, lib, options, flakes, ... }:

{
	imports = [
		./hardware-configuration.nix
		./transmission.nix
		flakes.musnix.nixosModules.default
	];

	# Hardware support
	boot = {
		kernelPackages = pkgs.linuxPackages_latest;

		kernelParams = [ "pcie_aspm=off" ];

		initrd.availableKernelModules = [
			"xhci_pci" "ehci_pci" "ahci" "nvme"
			"usb_storage" "usbhid" "uas" "sd_mod"
		];

		kernelModules = [ "nct6775" ];
	};

	musnix.enable = true;

	networking.hostName = "theseus";

	misc.uuid = "134829a8-d5f1-4f69-b500-35ebdf4d2ffb";

	time.timeZone = "America/Chicago";

	services = {
		atftpd.enable = true;

		vsftpd = {
			enable = true;
			localUsers = true;
			userlist = [ "anna" ];
			userlistEnable = true;
			chrootlocalUser = false;
		};

		gpsd = {
			enable = true;
			device = "/dev/ttyACM0";
		};

		xserver.displayManager.gdm.autoSuspend = false;
	};

	# virtualisation

	users.users.anna.extraGroups = [ "libvirtd" ];
	
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
