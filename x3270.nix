{ stdenv, openssl, m4
, libX11, libXt, libXaw, libXmu, bdftopcf, mkfontdir
, fontadobe100dpi, fontadobeutopia100dpi, fontbh100dpi
, fontbhlucidatypewriter100dpi, fontbitstream100dpi
, tcl
, ncurses }:

let
  majorVersion = "3";
  minorVersion = "6";
  versionSuffix = "ga8";
in stdenv.mkDerivation rec {
  pname = "x3270";
  version = "${majorVersion}.${minorVersion}${versionSuffix}";

  src = builtins.fetchurl {
    url = "http://x3270.bgp.nu/download/0${majorVersion}.0${minorVersion}/suite3270-${version}-src.tgz";
    sha256 = "1gv69iqdb0xv0bpxavzl5ill136sjgc35idd75769l9gli5i2x51";
  };

  patches = [
    ./0001-strip-bin-prefix.patch
  ];

  buildPhase = "make unix";

  nativeBuildInputs = [ m4 ];
  buildInputs = [
    libX11 libXt libXaw libXmu bdftopcf mkfontdir
    fontadobe100dpi fontadobeutopia100dpi fontbh100dpi
    fontbhlucidatypewriter100dpi fontbitstream100dpi
    tcl
    ncurses
  ];

  meta = with stdenv.lib; {
    description = "IBM 3270 terminal emulator for the X Window System";
    homepage = "http://x3270.bgp.nu/index.html";
    license = licenses.bsd3;
    maintainers = [ maintainers.dkudriavtsev ];
  };
}
