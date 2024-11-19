{ L, lib, ... }:

let
    inherit (lib)
        types
        mkOption
        ;
in rec {
    exports = self: { inherit (self)
        mkGenericOption
        hexString
        hexStringN
        ;
    };

    mkGenericOption = defaults: type: description: args:
        mkOption ({ inherit type description; } // defaults // args);

    # hexString : OptionType
    hexString = types.strMatching "^[[:xdigit:]]*$";

    # hexStringN : Num -> OptionType
    hexStringN = len: let
        n = toString len;
    in
        types.strMatching "^[[:xdigit:]]{${n}}$";
}