{ ... }:

{
	imports = [
		./hardware-configuration.nix
		./networking.nix

		./nginx.nix
		./synapse.nix
	];

	networking = {
		hostName = "neo";
		firewall.allowedTCPPorts = [ 80 443 ];
	};

	system.stateVersion = "20.03";
}
