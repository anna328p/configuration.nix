final: prev: 
{
	vlc = prev.vlc.override {
		libbluray = final.libbluray.override {
			withJava = true;
			withAACS = true;
			withBDplus = true;
		};
	};

	myWine = prev.wineWowPackages.full.override {
		# wineRelease = "staging"; # breaks FL Studio
		gtkSupport = true;
		vaSupport = true;
	};

	calibre = prev.calibre.overrideAttrs (oa: {
		buildInputs = oa.buildInputs ++ [ final.python3Packages.pycryptodome ];
	});

	gnome = prev.gnome.overrideScope' (gfinal: gprev: {
		yelp = gprev.yelp.overrideAttrs (_: {
			patches = [ ./yelp-no-smooth-scrolling.patch ];
		});
	});
}
