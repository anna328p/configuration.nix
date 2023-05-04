{ config, lib, flakes, ... }:

{
	imports = [
		flakes.nixos-hardware.nixosModules.common-cpu-amd-pstate
	];

	boot = {
		kernelModules = [ "kvm-amd" ];
		initrd.kernelModules = [ "amd-pstate" ];

		# TODO: set to active once openzfs supports linux 6.3+ 2023-04-28
		kernelParams = [ "amd_pstate=passive" ];  
	};

	nixpkgs.hostPlatform = lib.systems.examples.gnu64;
}
