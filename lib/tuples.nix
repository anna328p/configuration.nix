{ L, ... }:

with L; let
	inherit (builtins)
		isList length elemAt genList all
		isInt isFunction
		map foldl'
		;
in rec {
	exports = self: { inherit (self)
		singleton
		isTuple isPair
		mkTuple mkPair
		fst snd
		curry curryN
		uncurry uncurryN
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

	# append : [a] -> a -> [a]
	append = xs: x:
	    assert isList xs;
	    xs ++ [x];

    # curryFn : Nat -> Type -> Type -> Type
    # curryFn 1 a b = a -> b
    # curryFn n a b = a -> curryFn (n - 1) a b

    # curry : ([a] -> b) -> Nat n -> curryFn n a b
    curryN = f: n:
        assert isNat n;
        foldl' compose2 f (genList' append n) [];

    # mkTuple : Nat n -> curryFn n a [a]
    mkTuple = curryN id;

	# mkPair : a -> b -> (a, b)
	mkPair = a: b: [ a b ];
	
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

    # uncurry : Nat n -> (Any -> Any) -> Tuple n -> Any
    uncurryN = n: fn: xs:
        assert isNat n;
        assert isFunction fn;
        assert isTuple n xs;
        foldl' id fn xs;

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