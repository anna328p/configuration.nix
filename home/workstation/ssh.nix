{ lib, config, ... }:

{
    programs.ssh = {
        enable = true;
        compression = true;
        controlMaster = "auto";
        controlPersist = "30m";
        forwardAgent = true;

        matchBlocks = let
            mkServerBlocks = domain:
                (lib.flip lib.genAttrs) (name: {
                    user = config.home.username;
                    hostname = "${name}.${domain}";
                });
        in
            (mkServerBlocks "oci.ap5.network" [ "arachne" "angelia" "heracles" ]) //
            (mkServerBlocks "gcloud.ap5.network" [ "iris" ]) //
            (mkServerBlocks "zerotier.ap5.network" [ "theseus" ]) //
            {
                "github" = { user = "git"; hostname = "github.com"; };
                "gitlab" = { user = "git"; hostname = "gitlab.com"; };
            };
    };
}