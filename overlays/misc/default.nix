{ flakes, ... }:

final: prev: 
{
	mkFlakeVer = flake: prefix: let
		shortRev = builtins.substring 0 7 flake.rev;
	in
		prefix + "-git-" + shortRev;

	usbmuxd = prev.usbmuxd.overrideAttrs (_: rec {
		src = flakes.usbmuxd;

		version = final.mkFlakeVer src "1.1.2";
		RELEASE_VERSION = version;
	});

	idevicerestore = prev.idevicerestore.overrideAttrs (_: rec {
		src = flakes.idevicerestore;

		version = final.mkFlakeVer src "1.1.0";
		RELEASE_VERSION = version;
	});

	wrapDiscord = discordPkg: final.symlinkJoin {
		name = "${discordPkg.pname}-wrapped";
		paths = [ discordPkg ];
		buildInputs = [ final.makeWrapper ];
		postBuild = ''
			wrapProgram $out/bin/${discordPkg.meta.mainProgram} \
				--add-flags "--disable-smooth-scrolling"
		'';
	};

	libbluray_bd = prev.libbluray.override {
		withJava = true;
		withAACS = true;
		withBDplus = true;
	};

	mpv-unwrapped_bd = prev.mpv-unwrapped.override { libbluray = final.libbluray_bd; };
	mpv_bd = final.wrapMpv final.mpv-unwrapped_bd { };

	vlc_bd = prev.vlc.override { libbluray = final.libbluray_bd; };

	wine-custom = prev.wineWowPackages.full.override {
		wineRelease = "staging";
		gtkSupport = true;
		vaSupport = true;
		waylandSupport = true;
	};

	calibre = prev.calibre.overrideAttrs (oa: {
		buildInputs = oa.buildInputs ++ [ final.python3Packages.pycryptodome ];
	});

	gnome = prev.gnome.overrideScope' (gfinal: gprev: {
		yelp = gprev.yelp.overrideAttrs (_: {
			patches = [ ./yelp-no-smooth-scrolling.patch ];
		});

		gnome-control-center = gprev.gnome-control-center.override { gnome-remote-desktop = null; };
	});
}
