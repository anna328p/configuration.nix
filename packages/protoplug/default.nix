{ clangStdenv
, lib
, fetchFromGitHub
, pkg-config
, luajit
, fftw
, alsa-lib
, gtk3, freetype
, libX11, xorg
, curl
}:

clangStdenv.mkDerivation {
	pname = "protoplug";
	version = "1.4.0+git-6060a3b";

	src = fetchFromGitHub {
		owner = "pac-dev";
		repo = "protoplug";
		rev = "6060a3bcb3213ce890a9b781d29f702099127ddd";
		sha256 = "ku+1Vh4NfLQpahE9WSVmTthyPLsqR0vvZOgD2wPjTug=";
	};

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
