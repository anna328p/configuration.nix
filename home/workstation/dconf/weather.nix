{ lib, ... }:

{
    dconf.settings = let self = let
        inherit (lib.hm.gvariant)
            type
            mkVariant mkTuple mkUint32 mkString mkBoolean mkArray;

        inherit (type) tupleOf double;

        # reference:
        # https://github.com/GNOME/libgweather/blob/7f9f1e7510ddfb514de33f885d97ee64ac7f88a8/libgweather/gweather-location.c#L1423

        mkGWeatherLocation = {
            name,           # string
            stationCode,    # string
            isCity,         # boolean
            realLoc,        # Either (tupleOf [double double]) null
            parent ? null,  # Either (tupleOf [double double]) null
        }: let

            optionalPair = maybePair: let
                val = if maybePair == null
                    then []
                    else [(mkTuple maybePair)];
            in
                mkArray (tupleOf [double double]) val;

            format = 2;
        in
            # type: (v)
            # inner type: (uv)
            # inner type: (ssba(dd)a(dd))
                
            mkVariant (
                mkTuple [
                    (mkUint32 format)
                    (mkVariant (
                        mkTuple [
                            (mkString name)
                            (mkString stationCode)
                            (mkBoolean isCity)
                            (optionalPair realLoc)
                            (optionalPair parent)]))]);
    in {
        "org/gnome/shell/weather" = {
            locations = mkArray type.variant [
                (mkGWeatherLocation {
                    name = "Champaign-Urbana, IL";
                    stationCode = "KCMI";
                    isCity = false;
                    realLoc = [ 0.69869408078930939 (-1.5406603025593635) ];
                })
            ];

            automatic-location = true;
        };

        "org/gnome/Weather".locations = self."org/gnome/shell/weather".locations;

        "org/gnome/GWeather4" = {
            temperature-unit = "centigrade";
        };
    }; in self; 
}