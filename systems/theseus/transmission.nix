{ ... }:

{
	users.users.anna.extraGroups = [ "transmission" ];

	services.transmission = {
		enable = true;

		settings = {
			rpc-port = 9091;
			rpc-bind-address = "0.0.0.0";
			rpc-whitelist-enabled = false;

			rpc-authentication-required = "true";
			rpc-username = "anna";
			rpc-password = (builtins.readFile ./transmission-password.txt);

			peer-port = 25999;

			download-dir = "/media/storage/torrents";
			incomplete-dir = "/media/storage/torrents/incomplete";
			incomplete-dir-enabled = true;
		};
	};

	systemd.services.transmission.serviceConfig.BindPaths = [ "/media/storage" ];
}