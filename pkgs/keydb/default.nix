{ flakes, mkFlakeVer
, stdenv
, lib
, ... }:

stdenv.mkDerivation rec {
    pname = "keydb";

    src = flakes.keydb;
    version = "latest";

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
        dir="$out/etc/xdg/aacs"
        mkdir -p "$dir"
        cp $src "$dir/KEYDB.cfg"
    '';
}
