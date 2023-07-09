{ L, ... }:

let
    inherit (builtins)
        throw
        toString toJSON
        concatStringsSep

        isAttrs isBool isFloat isFunction
        isInt isList isPath isString 
        ;
in with L; rec {
    exports = self: { inherit (self)
        fontCss
        toLuaLiteral
        ;
    };

    # FontOpt : { name : Str; size : Num }
    # fontCss : FontOpt -> Str
    fontCss = opt: let
        inherit (opt) size name;
    in "${toString size}pt ${name}";

    # toTableRecord : Any -> Any -> Str
    toTableRecord = k: v: "[${k}] = ${v}";

    # mkTableLiteral : [Str] -> Str
    mkTableLiteral = fields: "{ ${concatStringsSep ", " fields} }";

    # setToLuaTable : Set -> Str
    setToLuaTable = let
        mkRecord = k: v: toTableRecord (toLuaLiteral k) (toLuaLiteral v);
        mkEntries = mapSetPairs (uncurry mkRecord);
    in
        o mkTableLiteral mkEntries;

    # listToLuaTable : List -> Str
    listToLuaTable = list:
        mkTableLiteral (map toLuaLiteral list);

    throwBadType = val:
        throw "value ${val} cannot be converted to a Lua literal";

    # toLuaLiteral : Any -> Str
    toLuaLiteral = val: let
        isNull = v: v == null;
        isNumber = v: isInt v || isFloat v;
        isStringLike = v: isString v || isPath v;

        isJSONLike = v: isNumber v || isStringLike v || isBool v;
    in
        if isNull val then
            "nil"
        else if isJSONLike val then
            toJSON val
        else if isAttrs val then
            setToLuaTable val
        else if isList val then
            listToLuaTable val
        else if isFunction val then
            throwBadType "<function>"
        else
            throwBadType (toString val);
}