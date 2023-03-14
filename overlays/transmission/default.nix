{ ... }:

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

	transmission = prev.transmission.overrideAttrs (oa: let
		version = "4.0.0-beta.1";
	in {
		inherit version;

		src = final.fetchFromGitHub {
			owner = "transmission";
			repo = "transmission";
			rev = "98cf7d9b3cd66f74b38b16b91be932b005a2b039";
			sha256 = "mwxbNlhFJxWTrY0MqQrIW/1Z/lURzvHzf9qAkq9Uiec=";

			fetchSubmodules = true;
		};

		buildInputs = (final.lib.lists.subtractLists (with prev; [
			libutp dht
		]) oa.buildInputs) ++ (with final; [
			libutp' dht'
			libdeflate libpsl
		]);

		# Whitelists have not yet updated
		patches = [
			./transmission-revert-version.patch
		];

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

		buildInputs = (final.lib.lists.subtractLists (with prev; [
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
