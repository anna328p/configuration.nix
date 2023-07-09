{ flakes, mkFlakeVer, replaceBuildInputs, ... }:

final: prev:
{
    transmission = let
        libutp' = final.libutp.overrideAttrs (oa: rec {
            src = flakes.libutp;
            version = mkFlakeVer src "3.4";
        });

        dht' = final.dht.overrideAttrs (oa: rec {
            src = flakes.dht;
            version = mkFlakeVer src "0.27";
        });

    in prev.transmission.overrideAttrs (oa: rec {
        src = flakes.transmission;
        version = mkFlakeVer src "4.0.2";

        buildInputs = replaceBuildInputs oa.buildInputs
            (with prev; [ libutp dht ])
            (with final; [ libutp' dht' libdeflate libpsl ]);

        cmakeFlags = oa.cmakeFlags ++ [ "-DENABLE_TESTS=OFF" ];

        patches = [];
    });

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
