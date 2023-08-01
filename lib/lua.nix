{ L, ... }:

let
    inherit (builtins)
        isAttrs isBool isFloat isFunction
        isInt isList isPath isString 

        all foldl'
        functionArgs attrNames attrValues
        throw
        concatStringsSep toJSON
        addErrorContext
        ;
in with L; rec {
    exports = self: { inherit (self)
        toLuaLiteral
        ;

    };

    # toTableRecord : Any -> Any -> Str
    toTableRecord = k: v: "[${k}] = ${v}";

    commaJoin = concatStringsSep ", ";

    # mkTableLiteral : [Str] -> Str
    mkTableLiteral = fields: "{ ${commaJoin fields} }";

    # setToLuaTable : Set -> Str
    setToTable = let
        mkRecord = on toTableRecord toLiteral;
        mkEntries = mapSetPairs (uncurry mkRecord);
    in
        o mkTableLiteral mkEntries;

    # listToLuaTable : List -> Str
    listToTable = list:
        mkTableLiteral (map toLiteral list);

    throwBadType = val:
        throw "value ${val} cannot be converted to a Lua literal";

    verbatim = str:
        assert isString str;
        { __luaVerbatim = true; inherit str; };

    __findFile = _: verbatim;

    _Call = obj: args: let
        target = if isString obj then obj else toLiteral obj;

        args' = if isAttrs args then [ args ] else args;
        argList = o commaJoin (map toLiteral) args';
    in
        assert orA2 isList isAttrs args;

        verbatim "${target}(${argList})";

    Call = o _Call Wrap;

    CallFrom = val: key: Call (Index val key);

    CallOn = obj: field: let
        fname = "(${toLiteral obj}):${field}";
    in
        assert isString field;
        _Call (verbatim fname);

    Chain = obj: fields:
        assert isList fields;
        assert all (f: isPair f && isString (fst f)) fields;

        foldl' (acc: uncurry (CallOn acc)) obj fields;


    Require = name: Call (verbatim "require") [ name ];

    Index = obj: key:
        verbatim "(${toLiteral obj})[${toLiteral key}]";

    Index' = obj: keys:
        assert isList keys;
        foldl' Index obj keys;

    Chunk = lines: verbatim (concatStringsSep "\n" (map toLiteral lines));

    Code = o toLiteral Chunk;

    If = cond: response: let
        response' = ({ Then, Else ? null }@arg: arg) response;

        consequence = if isList response
            then response
            else response'.Then;

        alternative = response'.Else;
        ifHasElse = v: if (response ? Else) then v else "";

        res = ''
            if (${toLiteral cond}) then
                ${toLiteral (Chunk consequence)}
            ${ifHasElse "else"}
                ${ifHasElse (toLiteral (Chunk alternative))}
            end
        '';
    in
        assert orA2 isList isAttrs response;
        assert (isAttrs response) -> (isList response'.Then);
        assert (isAttrs response) -> (response ? Else) -> (isList response'.Else);

        verbatim res;

    fnArgNames = fn: let
        args = functionArgs fn;
        argNames = attrNames args;
        isVariadic = hasEllipsis fn;

        res = argNames ++ (optional isVariadic "...");
    in
        assert isFunction fn;
        assert all (andA2 isBool not) (attrValues args);
        assert isBool isVariadic;
        res;

    substituteArgs = fn: args: let
        placeholders = genSet verbatim args;
    in
        fn placeholders;

    Function = fn: let
        args = fnArgNames fn;
        body = substituteArgs fn args;
        argList = commaJoin args;
    in
        assert isFunction fn;

        verbatim ''
            function(${argList})
                ${toLiteral (Chunk body)}
            end
        '';

    Return = args:
        assert isList args;
        verbatim "return ${commaJoin (map toLiteral args)}";

    ReturnOne = arg: Return [ arg ];

    Wrap = arg: verbatim "( ${toLiteral arg} )";

    # WARNING: nix alphabetically sorts names in a set pattern
    ForEach = iter: fn: let
        args = fnArgNames fn;
        body = substituteArgs fn args;
        argList = commaJoin args;
    in
        assert isFunction fn;
        
        verbatim ''
            for ${toLiteral argList} in ${toLiteral iter} do
                ${toLiteral (Chunk body)}
            end
        '';

    Pairs = t: Call (verbatim "pairs") [ t ];
    IPairs = t: Call (verbatim "ipairs") [ t ];

    SetLocal = name: value:
        verbatim ''
            local ${toLiteral name} = (${toLiteral value});
        '';

    Set = name: value: verbatim "${toLiteral name} = (${toLiteral value})";


    PrefixOp = op: val: verbatim "(${op}(${toLiteral val}))";

    BinOp = op: a: b: verbatim "((${toLiteral a}) ${op} (${toLiteral b}))";

    Count = PrefixOp "#";
    Neg = PrefixOp "-";

    Lt = BinOp "<";
    Gt = BinOp ">";
    Le = BinOp "<=";
    Ge = BinOp ">=";

    Eq = BinOp "==";
    Ne = BinOp "~=";

    Add = BinOp "+";
    Sub = BinOp "-";
    Mul = BinOp "*";
    Div = BinOp "/";
    Exp = BinOp "^";

    Cat = BinOp "..";

    And = BinOp "and";
    Or = BinOp "or";
    Not = PrefixOp "not";

    ListOp = op: let
        fn = concatMapStringsSep
            " ${op} "
            (item: "(${toLiteral item})");
    in
        o verbatim fn;

    And' = ListOp "and";
    Or' = ListOp "or";

    # toLiteral : Any -> Str
    toLiteral = val: let
        isLuaVerbatim = v: isAttrs v && (v.__luaVerbatim or false);

        isNumber = orA2 isInt isFloat;
        isStringLike = orA2 isString isPath;

        isJSONLike = v: isNumber v || isStringLike v || isBool v;
    in
        assert !(isFunction val);

        if val == null then
            "nil"
        else if isLuaVerbatim val then
            val.str
        else if isJSONLike val then
            toJSON val
        else if isAttrs val then
            setToTable val
        else if isList val then
            listToTable val
        else
            throwBadType (toString val);

    toLuaLiteral = toLiteral;
}