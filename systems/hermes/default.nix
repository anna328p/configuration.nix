{ config, pkgs, lib, localModules, flakes, ... }:
{
	imports = with localModules; [
		common_base
		common_physical
		common_workstation
		common_misc_amd

		flakes.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
		./disks.nix

		flakes.impermanence.nixosModule
		./persist-system.nix
		./persist-home.nix
	];

	boot = {
		# TODO: change back once openzfs supports 6.3+ 2023-04-28
		# kernelPackages = lib.mkForce pkgs.linuxPackages_testing;
		kernelPackages = lib.mkForce pkgs.linuxPackages_6_2;

		zfs.enableUnstable = true;

		kernelParams = [
			"iwlwifi.swcrypto=0" "bluetooth.disable_ertm=1"
			"pcie_aspm=force"
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

		cpuFreqGovernor = "schedutil";
	};

	services.postgresql.enable = true;

	home-manager.users.anna.imports = [ ./home ];

	environment.systemPackages = with pkgs; [ powertop ];

	system.stateVersion = "22.05";
}
# vim: noet:ts=4:sw=4:ai:mouse=a
