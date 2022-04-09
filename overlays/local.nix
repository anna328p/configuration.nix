self: super: let
	disableCheck = name: 
		{ "${name}" = super.${name}.overrideAttrs (_: { doCheck = false; }); };
in 
	disableCheck "virt-manager" //
{
	transgui = super.transgui.overrideAttrs (oldAttrs: {
		patches = [ ./0001-dedup-requestinfo-params.patch ];
	});

	myWine = super.wineWowPackages.full.override {
		# wineRelease = "staging"; # breaks FL Studio
		gtkSupport = true;
		vaSupport = true;
	};

	calibre = super.calibre.overrideAttrs (oa: {
		buildInputs = oa.buildInputs ++ [ super.python3Packages.pycryptodome ];
	});
}
