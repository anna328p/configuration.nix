{ flakes, callPackage, mkFlakeVer, ... }:

let
    callPackage' = file: args: let
        args' = args // { inherit flakes mkFlakeVer; };
    in
        callPackage file args';

in {
    protoplug = callPackage' ./protoplug { };
    keydb = callPackage' ./keydb { };
}
