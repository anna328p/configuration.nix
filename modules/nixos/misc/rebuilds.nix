{ config, lib, ... }:

let
    inherit (lib) mkOption mkIf types optional;
in {
    options.misc = {
        buildFull = mkOption {
            type = types.bool;
            description = "Whether to build expensive packages";
            default = true;
        };
    };

    config = let
        buildFull = config.misc.buildFull;
        isSmall = !buildFull;
    in {
        _module.args.ifFullBuild = mkIf buildFull;

        system.nixos = {
            tags = optional isSmall "small";
            variant_id = mkIf isSmall "small";
            variantName = mkIf isSmall "Small";
        };
    };

}