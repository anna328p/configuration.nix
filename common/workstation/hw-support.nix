{ config, pkgs, ... }:

{
	boot = {
		# Emulate ARM systems for remote deployments
		binfmt.emulatedSystems = [ "aarch64-linux" ];

		# Control connected monitors' settings
		kernelModules = [ "i2c-dev" "ddcci" ];
		extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
	};

	environment.systemPackages = with pkgs; [
		# DDC monitor control
		ddcutil

		# PostScript interpreter for printing
		ghostscript

		# Mouse config GUI
		piper

		# Steno keyboard support
		plover.dev

		# Smart cards, Yubikey
		opensc pcsctools yubikey-manager yubikey-manager-qt
	];

	# Mouse configuration
	services.ratbagd.enable = true;

	users.users.anna.extraGroups = [
		# Allow printing/scanning
		"lp" "scanner"

		# Allow i2c access for monitor control
		"i2c"
		
		# Allow ADB access to Android devices
		"adbusers"
	];

	# Create groups
	users.groups.i2c = {};
	users.groups.adbusers = {};

	# CUPS
	# can't be configured more declaratively :(
	services.printing = {
		enable = true;
		drivers = with pkgs; [
			gutenprint gutenprintBin
			brlaser
			hll2390dw-cups
		];
	};

	# Scanning
	hardware.sane = {
		enable = true;
		extraBackends = with pkgs; [ sane-airscan ];
	};

	# Android device debugging support
	programs.adb.enable = true;

	# Allow access to Apple devices via USB
	services.usbmuxd.enable = true;

	# Allow smart card and Yubikey access
	services.pcscd.enable = true;

	# Update device firmware
	services.fwupd.enable = true;

	# Misc
	hardware.bluetooth.enable = true;
}
