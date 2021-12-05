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
		acpi usbutils pciutils lm_sensors efibootmgr multipath-tools iotop
	];

	services.gpm.enable = true;
}
# vim: noet:ts=4:sw=4:ai:mouse=a
