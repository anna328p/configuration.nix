{ config, lib, flakes, localModules, ... }:

{
	imports = with localModules; [
		common.base
		common.physical
		common.workstation
		common.misc.amd

		flakes.musnix.nixosModules.default

		./hardware-configuration.nix
		./transmission.nix
	];

	# Hardware support
	boot = {
		kernelParams = [ "pcie_aspm=off" ];
		initrd.availableKernelModules = [ "usbhid" ];
		kernelModules = [ "nct6775" ];
	};

	musnix.enable = true;

	networking = {
		hostName = "theseus";
		hostId = "3c9184d4";
	};

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

		xserver.displayManager.gdm.autoSuspend = false;
	};

	home-manager.users.anna.imports = [ ./home ];

	system.stateVersion = "18.09"; # Do not change unless specified in release notes
}
# vim: noet:ts=4:sw=4:ai:mouse=a
