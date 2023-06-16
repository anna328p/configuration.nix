{ lib, ... }:

let
	inherit (builtins)
		foldl'
		isInt;
in rec {
	exports = self: { inherit (self) 
		id
		compose o compose2 oo
		flip
		pipe pipe'
		fix
		const
		isPositiveInt min max modulo pow;
	};

	# id : a -> a
	id = x: x;

	# compose : (b -> c) -> (a -> b) -> (a -> c)
	compose = f: g: x: f (g x);
	o = compose;

	# compose2 : (c -> d) -> (a -> b -> c) -> (a -> b -> d)
	oo = o o o;
	compose2 = oo;

	# flip : (a -> b -> c) -> (b -> a -> c)
	flip = f: a: b: f b a;

	# pipe : a -> [ (a -> b) (b -> c) ... (d -> e) ] -> e 
	pipe = foldl' (fn: val: fn val);

	# pipe' : [ (a -> b) (b -> c) ... (d -> e) ] -> a -> e 
	pipe' = foldl' (flip compose) id;

	# fix : (a -> a) -> a
	fix = f: let x = f x; in x;

	# const =
	#     sig forall (a: a _- (Fn Any _- a))

	# const : a -> (Any -> a)
	const = val: _: val;

	# isPositiveInt : Int -> Bool
	isPositiveInt = n:
		assert isInt n;
		n >= 0;

	# min : Int -> Int -> Int
	min = a: b: if a < b then a else b;

	# max : Int -> Int -> Int
	max = a: b: if a > b then a else b;

	# modulo : Int -> Int -> Int
	modulo = a: b: a - (a / b) * b;

	# pow : Int -> Int -> Int
	pow = base: exp:
		assert isPositiveInt exp;
		if exp == 0 then
			1
		else if exp == 1 then
			base
		else
			base * (pow base (exp - 1));
}
