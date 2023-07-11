{ lib, ... }:

let
    inherit (builtins)
        foldl'
        isInt;
in rec {
    exports = self: { inherit (self) 
        id const flip
        compose o compose2 oo
        pipe pipe'
        fix
        isPositiveInt min max modulo pow
        ;
    };

    # id : a -> a
    id = x: x;

    # const =
    #     sig forall (a: a _- (Fn [Any a])

    # const : a -> (Any -> a)
    const = val: _: val;

    # flip : (a -> b -> c) -> (b -> a -> c)
    flip = f: a: b: f b a;

    # compose : (b -> c) -> (a -> b) -> (a -> c)
    compose = f: g: x: f (g x);
    o = compose;

    # compose2 : (c -> d) -> (a -> b -> c) -> (a -> b -> d)
    oo = o o o;
    compose2 = oo;

    # pipe : a -> [ (a -> b) (b -> c) ... (d -> e) ] -> e 
    pipe = foldl' (fn: val: fn val);

    # pipe' : [ (a -> b) (b -> c) ... (d -> e) ] -> a -> e 
    pipe' = foldl' (flip compose) id;

    # fix : (a -> a) -> a
    fix = f: let x = f x; in x;
}