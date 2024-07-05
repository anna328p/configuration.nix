{ pkgs, ... }:

{
    programs.git = {
        package = pkgs.gitAndTools.gitFull;

        userName = "Anna Kudriavtsev";
        userEmail = "anna328p@gmail.com";

        ignores = [
            ".ccls_cache"
            ".direnv"
        ];
    };

    xdg.configFile = {
        "gh/config.yml".text = builtins.toJSON {
            version = "1";
            editor = "";
            git_protocol = "ssh";

            aliases = {
                rc = "repo create";
            };
        };

        # gh/hosts.yml is the credential store for gh.
        # For ssh key auth, gh defers to ssh to find keys, so this file
        # contains no secrets and can be generated declaratively.
        "gh/hosts.yml".text = builtins.toJSON {
            "github.com" = {
                users.anna328p = {};
                user = "anna328p";
                git_protocol = "ssh";
            };
        };
    };
}