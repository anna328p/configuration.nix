{ flakes, modulesPath, ... }:

{
	imports = [
		flakes.impermanence.nixosModule
		flakes.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
	];

	fileSystems = let
		dataset = subpath: {
			fsType = "zfs";
			device = "rpool/encrypt/${subpath}";
			neededForBoot = true;
		};
	in {
		# tmpfs on root
		"/" = { fsType = "tmpfs"; options = [ "size=100%" "huge=within_size" ]; };

		# EFI System Partition
		"/boot" = { device = "/dev/disk/by-uuid/EE41-5915"; };

		# Nix store
		"/nix" = dataset "volatile/nix";

		# Persistent data
		"/safe/system" = dataset "safe/system";
		"/safe/home" = dataset "safe/home";

		"/volatile/cache" = dataset "volatile/cache";
		"/volatile/steam" = dataset "volatile/steam";
	};

	swapDevices = [
		{ device = "/dev/disk/by-uuid/32f7549b-4744-4c8f-a6a1-9179eaec338a"; }
	];
}
