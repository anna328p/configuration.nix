{ localModules, ... }:

{
	imports = with localModules; [
		common_base
		common_server
		common_virtual

		./hardware-configuration.nix
		./networking.nix

		./nginx.nix
		./synapse.nix
	];

	nixpkgs.hostPlatform = lib.systems.examples.gnu64;

	networking = {
		hostName = "neo";
		firewall.allowedTCPPorts = [ 80 443 ];
	};

	system.stateVersion = "20.03";
}
