{ pkgs, ... }:

{
    programs = {
        git = {
            package = pkgs.gitAndTools.gitFull;

            userName = "Anna Kudriavtsev";
            userEmail = "anna328p@gmail.com";

            ignores = [
                ".ccls_cache"
                ".direnv"
            ];

            difftastic.enable = true;
        };

        gh = {
            enable = true;

            settings = {
                editor = "";
                git_protocol = "ssh";

                aliases = {
                    rc = "repo create";
                };
            };
        };

        gh-dash.enable = true;
    };

    xdg.configFile = {
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