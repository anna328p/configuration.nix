{ L, flakes, ... }:

let
    inherit (builtins)
        toXML
        isFunction
        ;

    parsec-xml = import ./contrib/parse-xml.nix {
        nix-parsec = flakes.parsec.lib;
        inherit L;
    };

    inherit (parsec-xml) parseXml;

in with L; {
    exports = self: { inherit (self) 
        hasEllipsis
        ;
    };

    # Return values:
    # true  : function with set pattern, with ellipsis
    # false : function with set pattern, without ellipsis
    # null  : function without set pattern

    # hasEllipsis : (a -> b) -> (Bool | Null)
    hasEllipsis = f: let
        findChild = name: obj: find (v: (v.name or null) == name) obj.children;

        parseRes = o parseXml toXML f;

        root = parseRes.value;
        expr = findChild "expr" root;
        func = findChild "function" expr;
        attrspat = findChild "attrspat" func;
    in
        assert isFunction f;

        if attrspat == null then
            null
        else
            (attrspat.attributes.ellipsis or null) == "1";
}