{ config, pkgs, lib, localModules, ... }:

{
	imports = with localModules; [
		common.base
		common.server
		common.virtual

		./hardware-configuration.nix
		./networking.nix
	];

	nixpkgs.hostPlatform = lib.systems.examples.gnu64;

	networking = {
		hostName = "leonardo";

		firewall = {
			# vsftpd, nginx
			allowedTCPPorts = [ 21 80 443 4567 ];

			# vsftpd
			allowedTCPPortRanges = [ { from = 51000; to = 51999; } ];
		};
	};

	services = {
		nginx = {
			enable = true;
			# Use recommended settings
			recommendedGzipSettings = true;
			recommendedOptimisation = true;
			recommendedProxySettings = true;
			recommendedTlsSettings = true;

			# Only allow PFS-enabled ciphers with AES256
			sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

			commonHttpConfig = ''
				map $scheme $hsts_header {
					https   "max-age=3600; includeSubdomains";
				}
				add_header Strict-Transport-Security $hsts_header;
				add_header 'Referrer-Policy' 'origin-when-cross-origin';
				# add_header X-Content-Type-Options nosniff;
				# add_header X-XSS-Protection "1; mode=block";
				proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
			'';

			virtualHosts = (let base = root': locations: {
				inherit locations;
				root = root';
				forceSSL = true;
				enableACME = true;
				http2 = true;
			};
			php = root': locations: base root' (locations // {
				"/" = {
					tryFiles = "$uri $uri/ /index.php$is_args$args";
					index = "index.php index.html";
				};
				"~ \\.php$".extraConfig = ''
					include ${pkgs.nginx}/conf/fastcgi.conf;
					fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
					fastcgi_pass  unix:${config.services.phpfpm.pools.mypool.socket};
					fastcgi_index index.php;
				'';
			});
			redirect = dest: {
				enableACME = true;
				forceSSL = true;
				globalRedirect = dest;
			}; in {
				### CONFIG START ###

				"dk0.us" = base "/var/www/dk0.us" {
					"= /.well-known/matrix/server".extraConfig =
						let server = { "m.server" = "synapse.neo.dk0.us:443"; }; in ''
							add_header Content-Type application/json;
							return 200 '${builtins.toJSON server}';
						'';
					"= /.well-known/matrix/client".extraConfig =
						let client = {
							"m.homeserver" = { "base_url" = "https://synapse.neo.dk0.us"; };
							"m.identity_server" = { "base_url" = "https://vector.im"; };
						}; in ''
							add_header Content-Type application/json;
							add_header Access-Control-Allow-Origin *;
							return 200 '${builtins.toJSON client}';
						'';
				};

				"mail.dk0.us" = php (pkgs.rainloop-community.override { dataPath = "/var/lib/rainloop"; }) {
					"^~ /data".extraConfig = "deny all;";
				};

				"boards.inexpensivecomputers.net" = php "/var/www/boards.inexpensivecomputers.net" {};
				"b.inexcomp.com" = redirect "boards.inexpensivecomputers.net";

				"leonardo.dk0.us" = base "/var/www/leonardo.dk0.us" {};
				"nixnest.org" = base "/var/www/nixnest.org" {};

				"nixnest.isfucking.gay" = redirect "nixnest.org";
				"google.isfucking.gay" = redirect "google.com";

				"_" = { root = "/var/www/leonardo.dk0.us"; };
			});
			appendHttpConfig = ''
				error_log stderr;
				access_log syslog:server=unix:/dev/log combined;
			'';
		};

		mysql = {
			enable = true;
			package = pkgs.mariadb;
			ensureDatabases = [ "boards" "iot" ];
			ensureUsers = [
				{ name = "nobody"; ensurePermissions = {
					"boards.*" = "ALL PRIVILEGES";
					"iot.*"    = "ALL PRIVILEGES";
				}; }
				{ name = "anna";   ensurePermissions = { "iot.*" = "ALL PRIVILEGES"; }; }
				{ name = "root";   ensurePermissions = { "*.*"   = "ALL PRIVILEGES"; }; }
			];
		};

		phpfpm = {
			phpPackage = pkgs.php82;
			pools.mypool = {
				user = "nobody";
				settings = {
					"listen.owner" = config.services.nginx.user;

					"pm" = "dynamic";
					"pm.max_children" = 5;
					"pm.start_servers" = 2;
					"pm.min_spare_servers" = 1;
					"pm.max_spare_servers" = 3;
					"pm.max_requests" = 500;

					"php_admin_value[error_log]" = "stderr";
					"php_admin_flag[log_errors]" = true;

					"catch_workers_output" = true;
				};
				phpEnv."PATH" = lib.makeBinPath [ pkgs.php82 ];
			};

			phpOptions = ''
				upload_max_filesize = 128M
				post_max_size = 128M
				max_file_uploads = 65535

			'';
				# extension=${pkgs.php.extensions.imagick}/lib/php/extensions/imagick.so
		};

		vsftpd = {
			enable = true;
			writeEnable = true;
			localUsers = true;
			userlist = [ "anna" ];
			userlistEnable = true;

			extraConfig = ''
				pasv_enable=Yes
				pasv_min_port=51000
				pasv_max_port=51999
			'';
		};
	};

	system.stateVersion = "19.09";
}
