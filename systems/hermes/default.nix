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

		kernelParams = [ "iomem=relaxed" "iwlwifi.swcrypto=0" "bluetooth.disable_ertm=1" ];
		kernelModules = [ "kvm-amd" "snd-seq" "snd-rawmidi" "nct6775" "v4l2loopback" ];
		extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

		supportedFilesystems = [ "zfs" ];
	};

	networking = {
		hostName = "hermes";
		domain = "ad.ap5.dev";
		hostId = "cda8da64";
	};

	time.timeZone = "America/Chicago";

	powerManagement = {
		enable = true;
		powertop.enable = true;
	};

	services = {
		xserver = {
			videoDrivers = [ "amdgpu" ];

			deviceSection = ''
				Option "VariableRefresh" "true"
				Option "TearFree" "true"
			'';
		};

		fwupd.enable = true;
		pcscd.enable = true;
	};

	environment.systemPackages = with pkgs; [
		powertop
		opensc pcsctools
	];

	virtualisation.libvirtd.enable = true;

	system.stateVersion = "20.09";
}
# vim: noet:ts=4:sw=4:ai:mouse=a
