{ lib, localModules, ... }:

{
	imports = with localModules; [
		common_base
		common_server
		common_virtual

		./hardware-configuration.nix
		./networking.nix # generated at runtime by nixos-infect
		./mail.nix
	];

	nixpkgs.hostPlatform = lib.systems.examples.gnu64;

	networking.hostName = "iris";

	system.stateVersion = "20.03";
}
