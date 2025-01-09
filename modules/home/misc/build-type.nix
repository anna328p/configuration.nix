{ lib, ... }:

{
    options.misc = {
        buildType = lib.mkOption {
            type = lib.types.enum [ "base" "workstation" ];
            default = "base";
            description = "The build type of the HM config";
        };
    };
}