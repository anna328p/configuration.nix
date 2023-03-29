{ pkgs, ... }:

{
	networking = {
		networkmanager = {
			enable = true;

			# Modern, more reliable wifi stack
			# wifi.backend = "iwd";
			# TODO: breaks authentication

			# Fix auth issues
			wifi.scanRandMacAddress = false;
		};

		# Just gets in the way on workstations
		firewall.enable = false;
	};

	environment.systemPackages = with pkgs; [
		nmap dnsutils
		mosh
	];

	users.users.anna.extraGroups = [ "networkmanager" "dialout" ];

	services = {
		# mDNS network discovery/advertisement
		avahi = {
			enable = true;
			ipv6 = true;
			nssmdns = true;
		};

		mullvad-vpn = {
			enable = true;
			package = pkgs.mullvad-vpn;
		};

		# Private LAN VPN
		zerotierone = {
			enable = true;
			joinNetworks = [
				"abfd31bd4777d83c" # annanet
				"abfd31bd479dc978" # linda
				"565799d8f678b97f" # mcserver
			];
		};

		syncthing = {
			enable = true;
			user = "anna";
			dataDir = "/home/anna";
			configDir = "/home/anna/.config/syncthing";
		};
	};

	# Reduce startup delay
	systemd.services.NetworkManager-wait-online.enable = false;
}
