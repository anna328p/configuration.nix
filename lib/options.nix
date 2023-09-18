{ L, lib }:

with lib; rec {
    mkGenericOption = defaults: type: description: args:
        mkOption ({ inherit type description; } // defaults // args);

    # hexString : OptionType
    hexString = types.strMatching "^[[:xdigit:]]*$";

    # hexStringN : Num -> OptionType
    hexStringN = len: let
        n = toString len;
    in
        types.strMatching "^[[:xdigit:]]{${n}}$";

    __ = "579ab340-13a4-4467-81d1-32ae4b7d5d1e"; # uuidgen -r

    unrollArgSequence = endRowPred: let
        inherit (L) flip mkMapping;
        inherit (builtins) listToAttrs;
    in {
        value = {};
        stack = [];

        __functor = self: arg: let
            newEntries = map (flip mkMapping arg) self.stack;

            value' = if endRowPred arg
                then self.value // (listToAttrs newEntries)
                else self.value;

            stack' = if endRowPred arg
                then [] 
                else self.stack ++ [ arg ];
        in
            if arg == __
                then self.value
                else self // {
                    value = value';
                    stack = stack';
                };
    };
}