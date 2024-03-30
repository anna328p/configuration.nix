{ config, lib, ... }:

let
    inherit (lib) mkOption mkIf types;
in {
    options.misc = {
        buildFull = mkOption {
            type = types.bool;
            description = "Whether to build expensive packages";
            default = true;
        };
    };

    config._module.args.ifFullBuild = mkIf config.misc.buildFull;
}