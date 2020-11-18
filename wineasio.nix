{ stdenv, fetchgit, wineWowPackages, system, asiosdk, libjack2, gcc_multi, pkgconfig }:

# TODO:
# - Wine should use ASIO for audio, see audio tab in winecfg.
#   To switch audio to ASIO edit registry HKEY_CURRENT_USER\Software\Wine\Drivers,
#   Add entry 'Audio=alsa'.
# - Wine can't find wineasio.dll.so, users need to put this in $wine/lib/wine
#   but users should not have to do this. Need to run wine64 regsvc32 wineasio.dll.so

let wine = wineWowPackages.unstable; in
  stdenv.mkDerivation rec {
    name = "wineasio-0.9.2";
    src = fetchgit {
      url = "https://github.com/wineasio/wineasio";
      rev = "e71741863fc89ac5c78eba2018ec1737499a287b";
      sha256 = "0an96bp683n7wwwwa2f6945v2pn4q2q6vn0v73kc0k5cqns11qc6";
      fetchSubmodules = true;
    };
    nativeBuildInputs = [ pkgconfig ];
    buildInputs = [ wine asiosdk libjack2 gcc_multi ];
    buildPhase = ''
      cp ${asiosdk}/common/asio.h .
      cp asio.h asio.h.i686
      chmod +w asio.h
      bash ./prepare_64bit_asio.sh
      ln -s ${wine}/include/wine .
      export PREFIX=${wine}
      export CFLAGS="$NIX_CFLAGS_COMPILE"
      echo "MAKE 11111111111"
      make 64 PREFIX=${wine}
      mv build64/wineasio.dll.so wineasio.dll.so.x86_64
      cp asio.h.i686 asio.h
      make clean
    '';
    installPhase = ''
      name=wineasio
      install -D -m755 $name.dll.so.x86_64 $out/lib/wine/$name.dll.so
    '';

    meta = {
      description = "ASIO driver for WINE";
      license = stdenv.lib.licenses.lgpl21;
      homepage = http://sourceforge.net/projects/wineasio/;
      maintainers = with stdenv.lib.maintainers; [ joelmo ];
    };
  }
