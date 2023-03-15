{ ... }:

{
	imports = [
		./hardware-configuration.nix
		./networking.nix # generated at runtime by nixos-infect
		./mail.nix
	];

	networking.hostName = "iris";

	system.stateVersion = "20.03";
}
