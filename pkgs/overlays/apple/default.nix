{ flakes, mkFlakeVer, ... }:

final: prev:
{
	usbmuxd = prev.usbmuxd.overrideAttrs (_: rec {
		src = flakes.usbmuxd;
		version = mkFlakeVer src "1.1.2";
		RELEASE_VERSION = version;
	});

	idevicerestore = prev.idevicerestore.overrideAttrs (_: rec {
		src = flakes.idevicerestore;
		version = mkFlakeVer src "1.1.0";
		RELEASE_VERSION = version;
	});
}
