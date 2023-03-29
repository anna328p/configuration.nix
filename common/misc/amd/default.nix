{ lib, flakes, ... }:

{
	imports = [
		flakes.nixos-hardware.nixosModules.common-cpu-amd-pstate
	];

	boot.kernelModules = [ "kvm-amd" ];

	nixpkgs.hostPlatform = lib.systems.examples.gnu64;
}
