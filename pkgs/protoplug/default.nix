{ flakes, mkFlakeVer
, clangStdenv, lib, fetchFromGitHub
, pkg-config, luajit, fftw, alsa-lib, gtk3, freetype, libX11, xorg, curl
, ... }:

clangStdenv.mkDerivation rec {
	pname = "protoplug";

	src = flakes.protoplug;
	version = mkFlakeVer src "1.4.0";

	nativeBuildInputs = [ pkg-config ];

	buildInputs = [
		luajit
		curl

		fftw
		alsa-lib

		gtk3 freetype
		xorg.libXinerama
		xorg.libXcursor
	];

	patchPhase = ''
		sed -i 's|/usr/share/ProtoplugFiles|'$out'/share/ProtoplugFiles|' Source/ProtoplugDir.cpp
	'';

	buildPhase = ''
		pushd Builds/multi/Linux
		make CONFIG=Release
	'';

	installPhase = ''
		popd
		pushd Bin/linux

		install -v -D -t $out/lib/vst "Lua Protoplug "*.so

		ln -sfv $out/lib/vst $out/lib/lxvst

		install -v -d $out/share
		cp -rv $src/ProtoplugFiles $out/share
	'';
}
