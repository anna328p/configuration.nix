{ config, pkgs, lib, ... }:
{
	imports = [
		./hardware-configuration.nix
		./persist-system.nix
		./persist-home.nix
	];

	boot = {
		initrd = {
			availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "rtsx_pci_sdmmc" ];
			kernelModules = [ "dm-snapshot" ];
			supportedFilesystems = [ "zfs" ];
		};

		kernelPackages = pkgs.linuxPackages_testing;

		kernelParams = [
			"iwlwifi.swcrypto=0" "bluetooth.disable_ertm=1"
			"zswap.enabled=1" "zswap.compressor=zstd"
		];

		supportedFilesystems = [ "zfs" ];
		zfs.enableUnstable = true;

		plymouth.enable = lib.mkForce false;
	};

	# identity

	networking = {
		hostName = "hermes";
		hostId = "6a5a4b0b";
	};

	misc.uuid = "46397c55-410c-4b6c-9050-5fbedb77e303";

	hardware.bluetooth.powerOnBoot = false;

	time.timeZone = "America/Chicago";

	powerManagement = {
		enable = true;
		powertop.enable = true;
	};

	services = {
		pcscd.enable = true;
		postgresql.enable = true;
	};

	home-manager.users.anna.imports = [ ./home ];

	environment.systemPackages = with pkgs; [
		powertop
		opensc pcsctools
		virt-manager
	];

	virtualisation.libvirtd.enable = true;
	virtualisation.podman.enable = true;

	system.stateVersion = "22.05";
}
# vim: noet:ts=4:sw=4:ai:mouse=a
