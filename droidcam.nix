{ stdenv, fetchFromGitHub, pkgconfig, ffmpeg, gtk2-x11, libjpeg }:

stdenv.mkDerivation rec {
  pname = "droidcam";
  version = "0";

  src = fetchFromGitHub {
    owner = "aramg";
    repo = "droidcam";
    rev = "03d6de8d5628663c75a6e266c4ae6a26a2bbe682";
    sha256 = "1cdaafpffg7266r441ivw1m105wj25saq13s3cb4brwjxg0mm798";
  };

  sourceRoot = "source/linux";

  buildInputs = [ pkgconfig ];
  nativeBuildInputs = [ ffmpeg gtk2-x11 libjpeg ];

  JPEG_DIR = libjpeg.out;

  installPhase = ''
    mkdir -p $out/bin
    cp droidcam droidcam-cli $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "DroidCam Linux client";
    homepage = https://github.com/aramg/droidcam;
  };
}
