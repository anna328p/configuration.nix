{ ... }:

{
	imports = [
		./hardware-configuration.nix
		./qbot.nix
	];

	networking = {
		hostName = "heracles";

		firewall.allowedTCPPorts = [ 4567 ];
	};

	system.stateVersion = "23.05";
}
