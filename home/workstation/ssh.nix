{ lib, config, ... }:

{
    programs.ssh = {
        enable = true;

        enableDefaultConfig = false;

        settings = let
            inherit (lib) genAttrs' nameValuePair;

            hostBlocks = domain: hosts: let
                block = hname:
                    nameValuePair "Host ${hname}" {
                        user = config.home.username;
                        hostname = "${hname}.${domain}";
                    };
            in
                genAttrs' hosts block;

        in {
            "Host *" = {
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

            "Host github" = { user = "git"; hostname = "github.com"; };
            "Host gitlab" = { user = "git"; hostname = "gitlab.com"; };
        }
        // (hostBlocks "oci.ap5.network" [ "arachne" "angelia" "heracles" ])
        // (hostBlocks "gcloud.ap5.network" [ "iris" ])
        // (hostBlocks "zerotier.ap5.network" [ "theseus" ])
        ;
    };
}