{ L, ... }:

with L; let
	inherit (builtins)
		isList length elemAt genList all
		isInt isFunction
		map
		;
in rec {
	exports = self: { inherit (self)
		singleton
		isTuple isPair
		mkTuple mkPair
		fst snd
		curry uncurry
		minListLength
		zip mapPairs zipMap
		pairAt
		;
	};

	# isTuple : Int -> [a] -> Bool
	isTuple = n: val:
		assert isInt n;
		isList val && (length val) == n;

	# isPair : [a] -> Bool
	isPair = isTuple 2;

	# singleton : a -> [a]
	singleton = val: [ val ];

	# mkTupleRes = Either [a] (a -> mkTupleRes)
	# mkTuple : Int -> a -> mkTupleRes
	mkTuple = n': let
		recurse = acc: n: val: let
			res = acc ++ singleton val;
		in
			if n == 1
				then res
				else recurse res (n - 1);
	in
		assert isInt n' && n' >= 1;
		recurse [] n';

	# mkPair : a -> b -> (a, b)
	mkPair = mkTuple 2;
	
	# fst : (a, b) -> a
	fst = pair:
		assert isPair pair;
		elemAt pair 0;

	# snd : (a, b) -> b
	snd = pair:
		assert isPair pair;
		elemAt pair 1;
	
	# curry : ((a, b) -> c) -> a -> b -> c
	curry = fn: a: b:
		assert isFunction fn;
		fn [ a b ];

	# uncurry : (a -> b -> c) -> (a, b) -> c
	uncurry = fn: pair:
		assert isFunction fn;
		assert isPair pair;
		fn (fst pair) (snd pair);

	# minListLength : [a] -> [b] -> Int
	minListLength = left: right:
		assert isList left;
		assert isList right;
		min (length left) (length right);

	# zip : [a] -> [b] -> [(a, b)]
	zip = left: right: let
		len = minListLength left right;
	in
		genList (pairAt left right) len;
	
	# mapPairs : (a -> b -> c) -> [(a, b)] -> c
	mapPairs = fn: list:
		assert isFunction fn;
		assert isList list;
		assert all isPair list;
		map (uncurry fn) list;
	
	# pairAt : [a] -> [b] -> Int -> (a, b)
	pairAt = left: right: i: mkPair (elemAt left i) (elemAt right i);

	# zipMap : (a -> b -> c) -> [a] -> [b] -> [c]
	zipMap = fn: left: right: let
		len = minListLength left right;
	in
		assert isFunction fn;
		genList (i: fn (elemAt left i) (elemAt right i)) len;
}