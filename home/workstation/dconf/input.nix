{ lib, ... }:

{
    dconf.settings = let
        inherit (lib.hm.gvariant)
            type
            mkTuple mkArray;

        inherit (type) string tupleOf;

        mkStrPairArray = list:
            mkArray (tupleOf [string string]) (map mkTuple list);
    in {
        "org/gnome/desktop/input-sources" = {
            sources = mkStrPairArray [
                [ "xkb" "us" ]
                [ "xkb" "semimak-jq" ]
                [ "xkb" "semimak-jqa" ]
                [ "xkb" "ru" ]
                [ "ibus" "mozc-jp" ]
            ];

            xkb-options = mkArray string [
                "terminate:ctrl_alt_bksp" "caps:escape"
            ];
        };

        "org/gnome/desktop/peripherals/mouse" = {
            accel-profile = "flat";
        };
    };
}