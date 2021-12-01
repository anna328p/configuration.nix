self: super: {
  transgui = super.transgui.overrideAttrs (oldAttrs: {
    patches = [ ./0001-dedup-requestinfo-params.patch ];
  });

  myWine = super.wineWowPackages.full.override {
    wineRelease = "staging";
    gtkSupport = true;
    vaSupport = true;
  };

  calibre = super.calibre.overrideAttrs (oa: {
    buildInputs = oa.buildInputs ++ [ super.python3Packages.pycryptodome ];
  });
}
