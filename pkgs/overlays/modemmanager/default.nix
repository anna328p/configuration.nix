{ flakes, mkFlakeVer, ... }:

final: prev: {
    modemmanager = prev.modemmanager.overrideAttrs (oa: {
        version = mkFlakeVer flakes.modemmanager-enz7360 "git";

        src = flakes.modemmanager-enz7360;
    });
}