{ ... }:

{
    intransience.datastores.home = {
        users.anna = {
            dirs = [
                { path = ".gnupg"; mode = "0700"; }
                { path = ".ssh"; mode = "0700"; }

                ".local/state"

                { path = ".local/share/keyrings"; mode = "0700"; }

                ".local/share/direnv"
                ".local/share/nvim/site"
                ".local/share/icc"
                ".local/share/TelegramDesktop"

                ".local/share/wine"
                ".local/share/Image-Line"

                ".config/syncthing"
                ".config/discord"
                ".config/easyeffects"
                ".config/keepassxc"

                ".config/Logseq"
                ".logseq"
                ".local/share/logseq"

                ".mozilla/firefox"
                ".mozilla/native-messaging-hosts"

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

    intransience.datastores.cache = {
        users.anna.dirs = [
            ".cache"
        ];
    };
}