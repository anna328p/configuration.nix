{ lib, ... }:

with lib; rec {
	exports = self: { inherit (self) 
		compose o compose2 oo
		pipe'

		fontCss;
	};

	# compose : (b -> c) -> (a -> b) -> (a -> c)
	compose = f: g: x: f (g x);
	o = compose;

	# compose2 : (c -> d) -> (a -> b -> c) -> (a -> b -> d)
	oo = o o o;
	compose2 = oo;

	# pipe' = [ (a -> b) (b -> c) ... (d -> e) ] -> a -> e 
	pipe' = flip pipe;
}
