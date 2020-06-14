{ mkDerivation, stdenv, lib, fetchgit, cmake, pkgconfig, git
, qt5, openal, glew, libpng, ffmpeg, libevdev, python3
, pulseaudioSupport ? true, libpulseaudio
, waylandSupport ? true, wayland
, alsaSupport ? true, alsaLib
, vulkanSupport ? true, vulkan-loader, vulkan-headers, vulkan-tools
}:

mkDerivation {
  pname = "rpcs3";
  version = "0.0.8-9300-341fdf7eb";

  src = fetchgit {
    url = https://github.com/RPCS3/rpcs3;
    rev = "341fdf7eb14763fd06e2eab9a4b2b8f1adf9fdbd";
    sha256 = "1qx97zkkjl6bmv5rhfyjqynbz0v8h40b2wxqnl59g287wj0yk3y1";
  };

  cmakeFlags = [
    "-DUSE_SYSTEM_LIBPNG=ON"
    "-DUSE_SYSTEM_FFMPEG=ON"
    "-DUSE_NATIVE_INSTRUCTIONS=OFF"
  ] ++ (if vulkanSupport then [ "-DUSE_VULKAN=ON" ] else [ "-DUSE_VULKAN=OFF" ]);

  nativeBuildInputs = [ cmake pkgconfig git ];

  buildInputs = [
    qt5.qtbase qt5.qtquickcontrols openal glew vulkan-loader libpng ffmpeg libevdev python3
  ] ++ lib.optional pulseaudioSupport libpulseaudio
    ++ lib.optional alsaSupport alsaLib
    ++ lib.optional vulkanSupport [ vulkan-headers vulkan-loader vulkan-tools ]
    ++ lib.optional waylandSupport wayland;

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "PS3 emulator/debugger";
    homepage = "https://rpcs3.net/";
    maintainers = with maintainers; [ abbradar nocent ];
    license = licenses.gpl2;
    platforms = [ "x86_64-linux" ];
  };
}
