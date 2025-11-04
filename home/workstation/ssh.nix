{ lib, config, ... }:

{
    programs.ssh = {
        enable = true;

        enableDefaultConfig = false;

        matchBlocks = let
            mkServerBlocks = domain:
                (lib.flip lib.genAttrs) (name: {
                    user = config.home.username;
                    hostname = "${name}.${domain}";
                });
        in
            {
                "*" = {
                    forwardAgent = true;
                    addKeysToAgent = "no";
                    compression = true;
                    serverAliveInterval = 0;
                    serverAliveCountMax = 3;
                    hashKnownHosts = false;
                    userKnownHostsFile = "~/.ssh/known_hosts";
                    controlMaster = "auto";
                    controlPath = "~/.ssh/master-%r@%n:%p";
                    controlPersist = "10m";
                };
            } //
            (mkServerBlocks "oci.ap5.network" [ "arachne" "angelia" "heracles" ]) //
            (mkServerBlocks "gcloud.ap5.network" [ "iris" ]) //
            (mkServerBlocks "zerotier.ap5.network" [ "theseus" ]) //
            {
                "github" = { user = "git"; hostname = "github.com"; };
                "gitlab" = { user = "git"; hostname = "gitlab.com"; };
            };
    };
}