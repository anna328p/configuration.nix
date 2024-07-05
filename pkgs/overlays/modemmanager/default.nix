{ flakes, mkFlakeVer, ... }:

final: prev: {
    modemmanager-enz7360 = prev.modemmanager.overrideAttrs (oa: {
        version = mkFlakeVer flakes.modemmanager-enz7360 "git";

        src = flakes.modemmanager-enz7360;

        mesonFlags = oa.mesonFlags ++ [
            "-Dplugin_intel=disabled"
            "-Dplugin_xmm7360=enabled"
        ];
    });
}