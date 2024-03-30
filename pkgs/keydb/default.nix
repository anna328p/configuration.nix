{ flakes
, stdenv
, unzip
, ... }:

stdenv.mkDerivation rec {
    pname = "keydb-eng";

    src = flakes.keydb;
    version = "latest";

    dontBuild = true;

    nativeBuildInputs = [ unzip ];

    unpackPhase = ''
        unzip "$src"
    '';

    installPhase = ''
        dir="$out/etc/xdg/aacs"

        install -d "$dir"
        install -T keydb.cfg "$dir/KEYDB.cfg"
    '';
}