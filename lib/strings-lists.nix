{ lib, L, using, ... }:

with L; let
	inherit (builtins)
		ceil
		isList length elemAt genList
		isString stringLength substring
		getAttr
		concatStringsSep;
in rec {
	exports = self: { inherit (self)
		singleton
		sublist
		repeatStr

		genericPad padList' padStr'
		leftPadList rightPadList
		leftPadStr rightPadStr

		slices' sliceListN sliceStrN

		addStrings
		concatStrings
		concatMapStringsSep concatMapStrings
		concatLines concatMapLines
		concat

		stringToChars
		mapStringChars' mapStringChars

		charToInt;
	};

	# singleton : a -> [a]
	singleton = val: [ val ];

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
	repeatStr = str: count:
		concatStringsSep "" (genList (_: str) count);

	# fixedWidthString : Int -> Str -> Str -> Str
	# TODO: implement
	# fixedWidthString = width: filler: str: null;

	# genericPad : (T a -> Num) -> (a -> Num -> T a) -> (T a -> T a -> T a) -> a -> Num -> T a -> T a
	genericPad = lenFn: mkPaddingFn: applyPadding:
		obj: len: src: let
			len' = lenFn src;
			padding = mkPaddingFn obj (len - len');
		in if len' >= len
			then src
			else applyPadding src padding;
	
	# padList' : ([a] -> [a] -> [a]) -> a -> Num -> [a] -> [a]
	padList' = genericPad length (o genList const);
	
	# leftPadList : a -> Num -> [a] -> [a]
	leftPadList = padList' (l: p: p ++ l);
	# rightPadList : a -> Num -> [a] -> [a]
	rightPadList = padList' (l: p: l ++ p);

	# padStr' : (Str -> Str -> Str) -> Char -> Num -> Str -> Str
	padStr' = genericPad stringLength repeatStr;
	
	# leftPadStr : Char -> Num -> Str -> Str
	leftPadStr = padStr' (s: p: p + s);
	# rightPadStr : Char -> Num -> Str -> Str
	rightPadStr = padStr' (s: p: s + p);

	# addStrings : Str -> Str -> Str
	addStrings = a: b: a + b;

	# slices' : (Num -> Num -> T a -> T a) -> (T a -> Num) -> Num -> T a -> [T a]
	slices' = subFn: lenFn: len: obj: let
		objLen = lenFn obj;
		nSlices = ceil (1.0 * objLen / len);
		getSlice = ix: subFn (ix * len) len obj;
	in
		genList getSlice nSlices;
	
	# sliceListN : Num -> [a] -> [[a]]
	sliceListN = slices' sublist length;
	# sliceStrN : Num -> Str -> [Str]
	sliceStrN = slices' substring stringLength;

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

	# mapStringChars' : (Int -> Str -> a) -> Str -> [a]
	mapStringChars' = fn: input: let
		mapFn = i: fn i (charAt input i);
	in
		assert isString input;
		genList mapFn (stringLength input);

	# mapStringChars : (Str -> a) -> Str -> [a]
	mapStringChars = fn: mapStringChars' (_: fn);
	
	asciiTable = import ./ascii-table.nix;

	charToInt = (flip getAttr) asciiTable;
}
