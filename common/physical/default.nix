{ config, pkgs, lib, ... }:

{
	boot.loader = {
		systemd-boot.enable = true;
		efi = {
			canTouchEfiVariables = true;
			efiSysMountPoint = "/boot";
		};
	};

	environment.systemPackages = with pkgs; [
		acpi

		# Query hardware configuration
		usbutils
		pciutils
		dmidecode

		# Sensors
		lm_sensors

		# Firmware integration
		efibootmgr
	];

	services.gpm.enable = true;
}
# vim: noet:ts=4:sw=4:ai:mouse=a