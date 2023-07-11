{ L, using, ... }:

with L; let
    inherit (builtins)
        isInt isFunction
        isList length elemAt genList
        isString stringLength substring
        getAttr
        concatStringsSep;
in rec {
    exports = self: { inherit (self)
        sublist
        repeatStr
        fixedWidthString
        init last

        genList'

        leftPadListObj rightPadListObj
        leftPadListList rightPadListList
        leftPadStr rightPadStr

        sliceListN sliceStrN

        addStrings
        concatStrings
        concatMapStringsSep concatMapStrings
        concatLines concatMapLines

        stringToChars
        imapStringChars mapStringChars

        charToInt;
    };

    # addLists : [a] -> [a] -> [a]
    addLists = a: b: a ++ b;

    # addStrings : Str -> Str -> Str
    addStrings = a: b: a + b;

    # sublist : Int -> Int -> List -> List
    sublist = start: count: list: let
        len = length list;

        trueCount = if (start + count) < len
            then count
            else if start >= len
                then 0
                else (len - start);
    in
        assert isPositiveInt start;
        assert isPositiveInt count;
        assert isList list;
        
        genList (i: elemAt list (i + start)) trueCount;

    charAt = str: index: let
        len = stringLength str;
    in
        assert isString str;
        assert isPositiveInt index;
        assert index < len;
        substring index 1 str;

    # repeatStr : Str -> Int -> Str
    repeatStr = str: count: concatStrings (genList' str count);

    # repeatStr : [a] -> Int -> [a]
    repeatList = list: count: concatLists (genList' list count);

    # init : [a] -> [a]
    init = list: let
        len = length list;
    in
        assert isList list;
        if len < 2 then
            []
        else
            genList (elemAt list) (len - 1);
    
    # last : [a] -> a
    last = list: let
        len = length list;
    in
        assert isList list;
        if (len == 0) then
            null
        else
            elemAt list (len - 1);

    # getLenFn = T a -> Int
    # mkRepeatFn = a -> Int -> T a
    # getSliceFn = T a -> Int -> Int -> T a
    # rtlFn = T a -> Int -> T a

    # rtlArg = Set (getLenFn | mkRepeatFn | getSliceFn)
    # repeatToLen' : rtlArg -> rtlFn
    repeatToLen' = { getLen, mkRepeat, getSlice }:
        filler: width: let
            fLen = getLen filler;
            nRep = ceilDiv fLen width;

            repeats = mkRepeat filler nRep;
        in
            if width == fLen * nRep
                then repeats
                else getSlice 0 width repeats;
    
    # repeatStrToLen : Str -> Int -> Str
    repeatStrToLen = repeatToLen' {
        getLen = stringLength;
        mkRepeat = repeatStr;
        getSlice = substring;
    };

    # repeatListToLen : [a] -> Int -> [a]
    repeatListToLen = repeatToLen' {
        getLen = length;
        mkRepeat = repeatList;
        getSlice = sublist;
    };

    # fixedWidthString : Int -> Str -> Str -> Str
    fixedWidthString = width: filler: str: let
        sLen = stringLength str;
        fLen = stringLength filler;

        nEmptySpaces = width - sLen;
        padding = repeatStrToLen filler nEmptySpaces;
    in
        assert isInt width;
        assert isString filler;
        assert fLen > 0;
        assert sLen < width;

        if nEmptySpaces == 0
            then str
            else padding + str;
    
    # genList' : a -> Int -> [a]
    genList' = o genList const;

    # predFn = Any -> Bool
    # getLenFn = T a -> Int
    # mkPadFn = a -> Int -> T a
    # joinFn = T a -> T a -> T a
    # padFn = a -> Int -> T a -> T a
    
    # genericPadArg : Set (predFn | getLenFn | mkPadFn | joinFn)

    # genericPad : predFn -> predFn -> getLenFn -> mkPadFn -> joinFn -> padFn
    genericPad = { isInnerType, isContainer, getLen, mkPad, join }:
        filler: width: input: let
            inputLen = getLen input;
            padding = mkPad filler width;
        in
            assert isInnerType filler;
            assert isInt width;
            assert isContainer input;

            if inputLen >= width
                then input
                else join input padding;

    padListObj' = join: genericPad {
        isInnerType = const true;
        isContainer = isList;
        getLen = length;
        mkPad = genList';
        inherit join;
    };

    # leftPadListObj : a -> Int -> [a] -> [a]
    leftPadListObj = padListObj' (flip addLists);

    # rightPadListObj : a -> Int -> [a] -> [a]
    rightPadListObj = padListObj' addLists;

    padListList' = join: genericPad {
        isInnerType = isList;
        isContainer = isList;
        getLen = length;
        mkPad = repeatListToLen;
        inherit join;
    };

    # leftPadListList : [a] -> Int -> [a] -> [a]
    leftPadListList = padListList' (flip addLists);

    # rightPadListList : [a] -> Int -> [a] -> [a]
    rightPadListList = padListList' addLists;

    padStr' = join: genericPad {
        isInnerType = isString;
        isContainer = isString;
        getLen = stringLength;
        mkPad = repeatStrToLen;
        inherit join;
    };

    # leftPadStr : Str -> Int -> Str -> Str
    leftPadStr = padStr' (flip addStrings);

    # rightPadStr : Str -> Int -> Str -> Str
    rightPadStr = padStr' addStrings;

    genericSliceN = { getLen, getSlice }:
        width: input: let
            inputLen = getLen input;
            nSlices = ceilDiv inputLen width;
            mkSlice = ix: getSlice (ix * width) width input;
        in
            genList mkSlice nSlices;
    
    # sliceListN : Int -> [a] -> [[a]]
    sliceListN = genericSliceN {
        getLen = length;
        getSlice = sublist;
    };

    # sliceStrN : Int -> Str -> [Str]
    sliceStrN = genericSliceN {
        getLen = stringLength;
        getSlice = substring;
    };

    concatStrings = concatStringsSep "";

    # concatMapStringsSep : Str -> (Str -> Str) -> [Str] -> Str
    concatMapStringsSep = sep: fn: list:
        concatStringsSep sep (map fn list);
    
    concatMapStrings = concatMapStringsSep "";

    # concatLines : [Str] -> Str
    concatLines = concatStringsSep "\n";

    # concatMapLines : (a -> Str) -> [a] -> Str;
    concatMapLines = concatMapStringsSep "\n";

    # stringToChars : Str -> [Str]
    stringToChars = input:
        assert isString input;
        genList (charAt input) (stringLength input);

    # imapStringChars : (Int -> Str -> a) -> Str -> [a]
    imapStringChars = fn: input: let
        mapFn = i: fn i (charAt input i);
    in
        assert isString input;
        genList mapFn (stringLength input);

    # mapStringChars : (Str -> a) -> Str -> [a]
    mapStringChars = o imapStringChars const;
    
    asciiTable = import ./ascii-table.nix;

    # isChar : Str -> Bool
    isChar = c: isString c && (stringLength c) == 1;

    charToInt = flip getAttr asciiTable;
}