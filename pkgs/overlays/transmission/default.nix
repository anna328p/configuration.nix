{ flakes, mkFlakeVer, replaceBuildInputs, ... }:

final: prev:
{
    transgui = prev.transgui.overrideAttrs (oa: rec {
        src = flakes.transgui;
        version = mkFlakeVer src "5.18.0";

        buildInputs = let
            lazarusQt = final.lazarus.override { withQt = true; };
        in
            replaceBuildInputs oa.buildInputs
                [ prev.lazarus ]
                [ final.libqt5pas lazarusQt ];

        nativeBuildInputs = [ final.qt5.wrapQtAppsHook ];
        qtWrapperArgs = "--prefix LD_LIBRARY_PATH : ${final.libqt5pas}/lib";

        patches = [ ./transgui-build-qt5.patch ];

        LCL_PLATFORM = "qt5";
    });
}