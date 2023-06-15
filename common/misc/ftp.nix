{ ... }:

{
	networking.firewall = {
		allowedTCPPorts = [ 21 ];
		allowedTCPPortRanges = [ { from = 51000; to = 51999; } ];
	};

	services.vsftpd = {
		enable = true;
		writeEnable = true;
		localUsers = true;

		extraConfig = ''
			pasv_enable=Yes
			pasv_min_port=51000
			pasv_max_port=51999
		'';
	};
}
