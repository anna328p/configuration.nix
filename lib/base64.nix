{ lib, L, using, ... }:

using {
	table = ./base64-table.nix;
} (s: with s; with lib; with L; rec {

	exports = self: { inherit (self)
		toBitGroups strToBitString strToBitList
		zeroPadN padSextet toBase64 toBase64Padded;
	};

	strToBitList = let
		charToByte = pipe' [
			(strings.charToInt)
			(toBaseDigits 2)
			(leftPadList 0 8)
		];
	in
		o (concatMap charToByte) stringToCharacters;

	strToBitString = o (concatMapStrings toString) strToBitList;

	zeroPadN = rightPadStr "0";

	toBitGroups = size: pipe' [
		(strToBitString)
		(sliceStrN size)
		(map (zeroPadN size))
	];

	toBase64 = let
		toSextets = toBitGroups 6;
		encodeSextet = (flip getAttr) toBase64Map;
	in
		o (concatMapStrings encodeSextet) toSextets;
	
	toBase64Padded = let
		ceilMod = base: i: i + mod (base - mod i base) base;
		paddedLength = o (ceilMod 4) stringLength;
		padB64 = str: rightPadStr "=" (paddedLength str) str;
	in
		o padB64 toBase64;
})
