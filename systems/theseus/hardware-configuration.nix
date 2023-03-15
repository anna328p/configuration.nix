{ lib, flakes, modulesPath, ... }:

{
	imports = [
		(modulesPath + "/installer/scan/not-detected.nix")
		flakes.nixos-hardware.nixosModules.common-pc-ssd
	];

	fileSystems = {
		"/" = {
			device = "/dev/disk/by-uuid/edcdb9c3-c01c-4d52-be10-d19879553f91";
			fsType = "btrfs";
			noCheck = true;
		};

		"/boot" = {
			device = "/dev/disk/by-uuid/3D04-D640";
			fsType = "vfat";
		};

		"/media/storage" = {
			device = "/dev/disk/by-uuid/d54cf5fb-f74d-46f1-9a2b-001c07fdb422";
			fsType = "btrfs";
			options = [ "nofail" "noauto" "x-systemd.automount" "compress-force=zstd" ];
		};

		"/media/backup" = {
			device = "/dev/disk/by-uuid/aad5ac37-057e-4f18-88ff-81632eefe237";
			fsType = "btrfs";
			options = [ "nofail" "noauto" "x-systemd.automount" "compress-force=zstd" ];
		};

		"/media/backup2" = {
			device = "/dev/disk/by-uuid/56cd0ce4-63a1-4146-873c-b565a19f5d10";
			fsType = "btrfs";
			options = [ "nofail" "noauto" "x-systemd.automount" "compress-force=zstd" ];
		};

		"/home" = {
			device = "/dev/disk/by-uuid/0d52b88d-3955-42b5-b091-6f8ffc3452ae";
			fsType = "btrfs";
			noCheck = true;
			options = [ "subvol=@home" "compress=zstd" ];
		};

		"/media/games" = {
			device = "/dev/disk/by-uuid/0d52b88d-3955-42b5-b091-6f8ffc3452ae";
			fsType = "btrfs";
			noCheck = true;
			options = [ "subvol=@games" "compress=zstd" ];
		};

		"/media/raw-home" = {
			device = "/dev/disk/by-uuid/0d52b88d-3955-42b5-b091-6f8ffc3452ae";
			fsType = "btrfs";
			noCheck = true;
			options = [ "subvol=/" "compress=zstd" ];
		};
	};

	swapDevices = [
		{ device = "/dev/disk/by-uuid/dc871ccb-2841-4b41-95dc-184fe08e3c77"; }
	];

	nix.settings.max-jobs = lib.mkDefault 24;
	powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
