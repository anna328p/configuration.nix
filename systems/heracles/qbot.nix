{ pkgs, lib, flakes, ... }:

{
	imports = [
		flakes.qbot.nixosModules.default
	];

	services.qbot = {
		enable = true;

		package = flakes.qbot.packages.${pkgs.system}.default;

		config = {
			token = builtins.readFile ../../secrets/qbot-token;

			client_id = 660591224482168842;
			owner = 165998239273844736;

			database = {
				type = "sqlite3";
				db = "db.sqlite3";
			};

			my_repo = "https://github.com/arch-community/qbot";

			modules = [
				"help" "util" "admin" "queries" "colors"
				"arch" "snippets" "figlet" "xkcd" "blacklist"
				"polls" "fun" "tokipona" "tio" "quotes"
				"bottom" "sitelenpona" "languages" "notes"
			];

			default_prefix = ".";

			bot_id_allowlist = [ 204255221017214977 ];
		};
	};
}
