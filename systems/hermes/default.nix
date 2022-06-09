{ config, pkgs, ... }:
{
	imports = [
		./hardware-configuration.nix
		./persist.nix
	];

	boot = {
		initrd = {
			availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "rtsx_pci_sdmmc" ];
			kernelModules = [ "dm-snapshot" ];
			supportedFilesystems = [ "zfs" ];
		};

		kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

		kernelParams = [ "iwlwifi.swcrypto=0" "bluetooth.disable_ertm=1" ];

		supportedFilesystems = [ "zfs" ];
	};

	networking = {
		hostName = "hermes";
		hostId = "cda8da64";
	};

	hardware.bluetooth.powerOnBoot = false;

	time.timeZone = "America/Los_Angeles";

	powerManagement = {
		enable = true;
		powertop.enable = true;
	};

	services = {
		pcscd.enable = true;
		postgresql.enable = true;
	};

	environment.systemPackages = with pkgs; [
		powertop
		opensc pcsctools
		virt-manager

		tetrio-desktop
	];

	virtualisation.libvirtd.enable = true;
	virtualisation.podman.enable = true;

	system.stateVersion = "20.09";
}
# vim: noet:ts=4:sw=4:ai:mouse=a
