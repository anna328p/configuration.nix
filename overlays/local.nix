self: super: 
{
	vlc = super.vlc.override {
		libbluray = self.libbluray.override {
			withJava = true;
			withAACS = true;
			withBDplus = true;
		};
	};

	myWine = super.wineWowPackages.full.override {
		# wineRelease = "staging"; # breaks FL Studio
		gtkSupport = true;
		vaSupport = true;
	};

	calibre = super.calibre.overrideAttrs (oa: {
		buildInputs = oa.buildInputs ++ [ self.python3Packages.pycryptodome ];
	});

	gnome = super.gnome.overrideScope' (gself: gsuper: {
		yelp = gsuper.yelp.overrideAttrs (_: {
			patches = [ ./yelp-no-smooth-scrolling.patch ];
		});
	});

	libdeflate_1_14 = self.libdeflate.overrideAttrs (oa: rec {
		version = "1.14";

		src = self.fetchFromGitHub {
			owner = "ebiggers";
			repo = "libdeflate";
			rev = "v${version}";
			sha256 = "SNs10AI+xdqLWGVmG59U2H78i437j3Lly7eOvWxNxic=";
		};

		patches = [];
	});

	libutp' = self.libutp.overrideAttrs (oa: let
		branch = "post-3.4-transmission";
	in {
		version = "unstable-${branch}";

		src = self.fetchFromGitHub {
			owner = "transmission";
			repo = "libutp";
			rev = "059c9449a104e440e4f913756a5f560dd4ae76a9";
			sha256 = "BgXaitIwXU4jCBkmovNrRIRA/VtMb/80KfqH2ldJZVA=";
		};
	});

	dht' = self.dht.overrideAttrs (oa: {
		version = "0.27";

		src = self.fetchFromGitHub {
			owner = "transmission";
			repo = "dht";
			rev = "015585510e402a057ec17142711ba2b568b5fd62";
			sha256 = "m4utcxqE3Mn5L4IQ9UfuJXj2KkXXnqKBGqh7kHHGMJQ=";
		};
	});

	transmission = super.transmission.overrideAttrs (oa: let
		version = "4.0.0-beta.1";
	in {
		inherit version;

		src = self.fetchFromGitHub {
			owner = "transmission";
			repo = "transmission";
			rev = version;
			sha256 = "mwxbNlhFJxWTrY0MqQrIW/1Z/lURzvHzf9qAkq9Uiec=";
		};

		buildInputs = (super.lib.lists.subtractLists (with super; [
			libutp dht
		]) oa.buildInputs) ++ (with self; [
			libutp' dht'
			libdeflate_1_14 libpsl
		]);

		# Whitelists have not yet updated
		patches = [
			(self.fetchpatch {
				name = "set-version-4-beta.patch";
				url = "https://github.com/transmission/transmission/commit/2fe473b586e99886a022651cd7634f567218bc8e.patch";
				sha256 = "trlelEuMzMNbv/y68etqQUbHPvYUb+BhHhy70GpMSUc=";

				revert = true;
			})
		];
	});

	transgui = super.transgui.overrideAttrs (oa: {
		version = "unstable-2022-09-17";

		src = self.fetchFromGitHub {
			owner = "transmission-remote-gui";
			repo = "transgui";
			rev = "1c81df7fa318eb3b1af23e6fd6bd537b3f8ba3c9";
			sha256 = "+3MYEz++CdPRF42AqUq5NHFAsUPmdhYT83I7NXV2AVk=";
		};

		patches = [];
	});
}
