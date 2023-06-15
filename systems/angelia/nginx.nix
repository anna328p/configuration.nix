{ pkgs, ... }:

{
	services.nginx = {
		enable = true;
		# Use recommended settings
		recommendedGzipSettings = true;
		recommendedOptimisation = true;
		recommendedProxySettings = true;
		recommendedTlsSettings = true;

		# Only allow PFS-enabled ciphers with AES256
		sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

		virtualHosts = (let base = root': locations: {
			inherit locations;
			root = root';
			forceSSL = true;
			enableACME = true;
			http2 = true;
		};
		redirect = dest: {
			enableACME = true;
			forceSSL = true;
			globalRedirect = dest;
		}; in {
			"synapse.angelia.ap5.network" = {
				enableACME = true;
				forceSSL = true;

				locations."/".extraConfig = ''
					return 404;
				'';

				locations."/_matrix" = {
					proxyPass = "http://[::1]:8008";
				};
			};

			" synapse.angelia.ap5.network" = {
				useACMEHost = "synapse.angelia.ap5.network";
				onlySSL = true;

				listen = [ { addr = "0.0.0.0"; port = 8448; ssl = true; } ];

				locations."/" = {
					proxyPass = "http://[::1]:8008";
				};
			};

			"angelia.ap5.network" = base pkgs.element-web { };
			"element.angelia.ap5.network" = base pkgs.element-web { };

			"riot.angelia.ap5.network" = redirect "angelia.ap5.network";
		});

		appendHttpConfig = ''
			error_log stderr;
			access_log syslog:server=unix:/dev/log combined;
		'';
	};
}
