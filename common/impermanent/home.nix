{ ... }:

{
    environment.persistence.home = {
        users.anna = {
            directories = [
                { directory = ".gnupg"; mode = "0700"; }
                { directory = ".ssh"; mode = "0700"; }
                { directory = ".local/share/keyrings"; mode = "0700"; }

                ".local/state"

                ".local/share/direnv"
                ".local/share/nvim/site"
                ".local/share/icc"

                ".config/syncthing"
                ".config/discord"
                ".local/share/TelegramDesktop"
                ".config/easyeffects"

                ".local/share/wine"

                ".config/Logseq"
                ".logseq"
                ".local/share/logseq"

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

    environment.persistence.cache = {
        users.anna = {
            directories = [
                ".cache"
            ];
        };
    };
}