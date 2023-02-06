{ lib, L, ... }:

with lib; with L; rec {
	exports = self: { inherit (self) toBase64Map; };

	array = [
		"A" "B" "C" "D" "E" "F" "G" "H"
		"I" "J" "K" "L" "M" "N" "O" "P"
		"Q" "R" "S" "T" "U" "V" "W" "X"
		"Y" "Z" "a" "b" "c" "d" "e" "f"
		"g" "h" "i" "j" "k" "l" "m" "n"
		"o" "p" "q" "r" "s" "t" "u" "v"
		"w" "x" "y" "z" "0" "1" "2" "3"
		"4" "5" "6" "7" "8" "9" "+" "/"
	];

	mkBitMap = let
		numToBinSextet = pipe' [
			(toBaseDigits 2)
			(concatMapStrings toString)
			(leftPadStr "0" 6)
		];

		genMapping = o nameValuePair numToBinSextet;
	in
		o listToAttrs (imap0 genMapping);
	
	toBase64Map = mkBitMap array;
}
