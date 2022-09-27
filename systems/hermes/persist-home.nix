{ ... }:

{
	environment.persistence."/safe/home" = {
		hideMounts = true;

		users.anna = {
			directories = [
				{ directory = ".gnupg"; mode = "0700"; }
				{ directory = ".ssh"; mode = "0700"; }
				{ directory = ".local/share/keyrings"; mode = "0700"; }

				".local/state"

				".cache/zsh"
				".local/share/direnv"
				".local/share/nvim/site"
				".local/share/icc"

				".config/syncthing"
				".config/discord"
				".local/share/TelegramDesktop"

				".mozilla/firefox"

				"Documents"
				"Music"
				"Pictures"
				"Videos"
				"Sync"

				"work"
			];

			files = [
				".local/share/zsh/zsh_history"
			];
		};
	};
}
# vim: noet:ts=4:sw=4:ai:mouse=a
