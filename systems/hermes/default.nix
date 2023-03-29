{ config, pkgs, lib, localModules, ... }:
{
	imports = with localModules; [
		common.base
		common.physical
		common.workstation
		common.misc.amd

		./hardware-configuration.nix
		./persist-system.nix
		./persist-home.nix
	];

	boot = {
		kernelPackages = lib.mkForce pkgs.linuxPackages_testing;
		zfs.enableUnstable = true;

		kernelParams = [
			"iwlwifi.swcrypto=0" "bluetooth.disable_ertm=1"
		];

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
	];

	system.stateVersion = "22.05";
}
# vim: noet:ts=4:sw=4:ai:mouse=a
