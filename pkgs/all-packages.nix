{ flakes, callPackage, mkFlakeVer, ... }:

let
    callPackage' = file: args: let
        args' = args // { inherit flakes mkFlakeVer; };
    in
        callPackage file args';

in {
    keydb = callPackage' ./keydb { };

    neovim-ruby-env = callPackage' ./neovim-ruby-env { };

    iso-x86_64 = callPackage' ./iso-x86_64 { };
}