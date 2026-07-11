{ lib, pkgs, config, ... }:

{
    # interface
    options.services.any-sync = let
        inherit (lib)
            mkOption
            mkEnableOption
            ;

        t = lib.types;
    in {
        coordinator = {};

        consensusnode = {};

        node = t.attrsOf t.submodule ({ ... }: {

        });

        filenode = t.attrsOf t.submodule ({ ... }: {

        });
    };

    # implementation
    config = let
        cfg = config.services.any-sync;
    in {

    };
}