{ pkgs, ... }:

{
    programs = {
        git = {
            package = pkgs.gitAndTools.gitFull;

            userName = "Anna Kudriavtsev";
            userEmail = "anna328p@gmail.com";
        };

        gh = {
            enable = true;

            settings = {
                git_protocol = "ssh";
                aliases.rc = "repo create";
            };
        };
    };

    # gh/hosts.yml is the credential store for gh.
    # For ssh key auth, gh defers to ssh to find keys, so this file
    # contains no secrets and can be generated declaratively.
    xdg.configFile."gh/hosts.yml".text = builtins.toJSON {
        "github.com" = {
            user = "anna328p";
            git_protocol = "ssh";
        };
    };
}