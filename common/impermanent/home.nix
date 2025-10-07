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
                ".local/share/evolution"
                ".local/share/Google"
                ".local/share/icc"
                ".local/share/nvim/site"
                ".local/share/TelegramDesktop"

                ".local/share/wine"
                ".local/share/Image-Line"

                ".config/discord"
                ".config/easyeffects"
                ".config/evolution"
                ".config/github-copilot"
                ".config/goa-1.0"
                ".config/gcloud"
                ".config/Google"
                ".config/ideavim"
                ".config/keepassxc"
                ".config/PrusaSlicer"
                ".config/syncthing"

                ".config/Logseq"
                ".logseq"
                ".local/share/logseq"

                ".mozilla/firefox"
                ".mozilla/native-messaging-hosts"

                ".steam"
                ".local/share/Steam"

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