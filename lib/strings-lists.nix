{ lib, L, ... }:

with lib; with L; rec {
	exports = self: { inherit (self)
		genericPad padList' padStr'
		leftPadList rightPadList
		leftPadStr rightPadStr

		slices' sliceListN sliceStrN

		addStrings
		concatLines concatMapLines;
	};

	# genericPad : (T a -> Num) -> (a -> Num -> T a) -> (T a -> T a -> T a) -> a -> Num -> T a -> T a
	genericPad = lenFn: mkPaddingFn: applyPadding:
		obj: len: src: let
			len' = lenFn src;
			padding = mkPaddingFn obj (len - len');
		in if len' >= len
			then src
			else applyPadding src padding;
	
	# padList' : ([a] -> [a] -> [a]) -> a -> Num -> [a] -> [a]
	padList' = genericPad
		length
		(obj: size: genList (_: obj) size);
	
	# leftPadList : a -> Num -> [a] -> [a]
	leftPadList = padList' (l: p: p ++ l);
	# rightPadList : a -> Num -> [a] -> [a]
	rightPadList = padList' (l: p: l ++ p);

	# padStr' : (Str -> Str -> Str) -> Char -> Num -> Str -> Str
	padStr' = genericPad
		stringLength
		(char: size: fixedWidthString size char "");
	
	# leftPadStr : Char -> Num -> Str -> Str
	leftPadStr = padStr' (s: p: p + s);
	# rightPadStr : Char -> Num -> Str -> Str
	rightPadStr = padStr' (s: p: s + p);

	# addStrings : Str -> Str -> Str
	addStrings = a: b: a + b;

	# slices' : (Num -> Num -> T a -> T a) -> (T a -> Num) -> Num -> T a -> [T a]
	slices' = subFn: lenFn: len: obj: let
		inherit (builtins) ceil;

		objLen = lenFn obj;
		nSlices = ceil (1.0 * objLen / len);
		getSlice = ix: subFn (ix * len) len obj;
	in
		genList getSlice nSlices;
	
	# sliceListN : Num -> [a] -> [[a]]
	sliceListN = slices' sublist length;
	# sliceStrN : Num -> Str -> [Str]
	sliceStrN = slices' substring stringLength;

	# concatLines : [Str] -> Str
	concatLines = concatStringsSep "\n";

	# concatMapLines : (a -> Str) -> [a] -> Str;
	concatMapLines = concatMapStringsSep "\n";
}
