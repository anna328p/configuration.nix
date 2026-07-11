{ ... }:

{
    intransience.datastores.home = {
        users.anna = {
            dirs = [
                { path = ".gnupg"; mode = "0700"; }
                { path = ".ssh"; mode = "0700"; }

                ".local/state"

                { path = ".local/share/keyrings"; mode = "0700"; }

                ".local/share/Anki2"
                ".local/share/direnv"
                ".local/share/easyeffects"
                ".local/share/evolution"
                ".local/share/Google"
                ".local/share/icc"
                ".local/share/nvim/site"
                ".local/share/TelegramDesktop"

                ".local/share/wine"
                ".local/share/Image-Line"

                ".config/.android"
                ".config/Android Open Source Project"
                ".config/ideavim"

                ".config/anytype"
                ".config/discord"
                ".config/evolution"
                ".config/github-copilot"
                ".config/goa-1.0"
                ".config/gcloud"
                ".config/GIMP"
                ".config/Google"
                ".config/keepassxc"
                ".config/PrusaSlicer"
                ".config/Signal"
                ".config/syncthing"

                ".config/Logseq"
                ".logseq"
                ".local/share/logseq"

                ".chirp"

                ".claude"
                ".codex"

                ".config/mozilla/firefox"
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
                ".local/share/nix/trusted-settings.json"
                ".claude.json"
            ];
        };
    };

    intransience.datastores.cache = {
        users.anna.dirs = [
            ".cache"

            ".android"
            ".gradle"
        ];
    };
}