final: prev:
{
	libutp' = final.libutp.overrideAttrs (oa: let
		branch = "post-3.4-transmission";
	in {
		version = "unstable-${branch}";

		src = final.fetchFromGitHub {
			owner = "transmission";
			repo = "libutp";
			rev = "059c9449a104e440e4f913756a5f560dd4ae76a9";
			sha256 = "BgXaitIwXU4jCBkmovNrRIRA/VtMb/80KfqH2ldJZVA=";
		};
	});

	dht' = final.dht.overrideAttrs (oa: {
		version = "0.27";

		src = final.fetchFromGitHub {
			owner = "transmission";
			repo = "dht";
			rev = "015585510e402a057ec17142711ba2b568b5fd62";
			sha256 = "m4utcxqE3Mn5L4IQ9UfuJXj2KkXXnqKBGqh7kHHGMJQ=";
		};
	});

	transmission = prev.transmission.overrideAttrs (oa: rec {
		version = "4.0.1";

		src = final.fetchFromGitHub {
			owner = "transmission";
			repo = "transmission";
			rev = version;
			sha256 = final.lib.fakeSha256;

			fetchSubmodules = true;
		};

		buildInputs = (final.lib.subtractLists (with prev; [
			libutp dht
		]) oa.buildInputs) ++ (with final; [
			libutp' dht'
			libdeflate libpsl
		]);

		cmakeFlags = oa.cmakeFlags ++ [
			"-DENABLE_TESTS=OFF"
		];
	});

	transgui = prev.transgui.overrideAttrs (oa: {
		version = "unstable-2022-09-17";

		src = final.fetchFromGitHub {
			owner = "transmission-remote-gui";
			repo = "transgui";
			rev = "1c81df7fa318eb3b1af23e6fd6bd537b3f8ba3c9";
			sha256 = "+3MYEz++CdPRF42AqUq5NHFAsUPmdhYT83I7NXV2AVk=";
		};

		buildInputs = (final.lib.subtractLists (with prev; [
			lazarus
		]) oa.buildInputs) ++ (with final; [
			(lazarus.override { withQt = true; })
			libqt5pas
		]);

		nativeBuildInputs = [ final.qt5.wrapQtAppsHook ];
		qtWrapperArgs = "--prefix LD_LIBRARY_PATH : ${final.libqt5pas}/lib";

		patches = [ ./transgui-build-qt5.patch ];

		LCL_PLATFORM = "qt5";
	});
}
