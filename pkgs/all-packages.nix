{ flakes, pkgs, mkFlakeVer, ... }:

let
    inherit (pkgs) callPackage;

    callPackage' = file: args: let
        args' = args // { inherit flakes mkFlakeVer; };
    in
        callPackage file args';

    rubyNix = flakes.ruby-nix.lib pkgs;

in rec {
    keydb = callPackage' ./keydb { };

    neovim-ruby-env = callPackage' ./neovim-ruby-pkgs { inherit rubyNix; };

    iso-x86_64 = callPackage' ./iso-x86_64 { };
}