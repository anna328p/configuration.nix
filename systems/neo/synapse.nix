{ ... }:

{
	services = {
		# matrix-synapse = {
		# 	enable = true;
		# 	server_name = "dk0.us";
		# 	listeners = [
		# 		{
		# 			port = 8008;
		# 			bind_address = "::1";
		# 			type = "http";
		# 			tls = false;
		# 			x_forwarded = true;
		# 			resources = [
		# 				{ names = [ "client" "federation" ]; compress = false; }
		# 			];
		# 		}
		# 	];

		# 	enable_registration = true;

		# 	database_type = "psycopg2";
		# 	database_args = {
		# 		password = "synapse";
		# 	};

		# 	verbose = "1";


		# 	app_service_config_files = [
		# 		"/etc/dr.yaml"
		# 	];
		# };

		# matrix-appservice-discord = {
		# 	enable = true;
		# 	environmentFile = /etc/keyring/matrix-appservice-discord/tokens.env;
		# 	settings = {
		# 		bridge = {
		# 			domain = "dk0.us";
		# 			homeserverUrl = "https://synapse.neo.dk0.us";
		# 		};
		# 	};
		# };

		# postgresql = {
		# 	enable = true;
		# 	initialScript = pkgs.writeText "synapse-init.sql" ''
		# 		CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse' CREATEDB;
		# 		CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
		# 			TEMPLATE template0
		# 			LC_COLLATE = "C"
		# 			LC_CTYPE = "C";
		# 		GRANT ALL PRIVILEGES ON DATABASE "matrix-synapse" TO "matrix-synapse";
		# 	'';
		# };
	};

	environment.variables = {
		"SYNAPSE_CACHE_FACTOR" = "2.0";
	};

}
