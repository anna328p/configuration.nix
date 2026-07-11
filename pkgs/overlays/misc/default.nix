{ flakes, mkFlakeVer, ... }:

final: prev: let
    rubyVer = "3_4";

    overrideCmake = pkg: pkg.overrideAttrs (oa: {
        cmakeFlags = (oa.cmakeFlags or []) ++ [
            "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
        ];
    });

    disableCheck = pkg: pkg.overrideAttrs (oa: {
        doCheck = false;
    });

    disableInstallCheck = pkg: pkg.overrideAttrs (oa: {
        doInstallCheck = false;
    });

    inherit (final.stdenv.hostPlatform) system;

    pkgsMaster = import flakes.nixpkgs-master {
        inherit system;
        config.allowUnfree = true;
    };

    firefoxPkgs = flakes.firefox-nightly.packages.${system};
in {
    ruby_latest = final."ruby_${rubyVer}";
    rubyPackages_latest = final."rubyPackages_${rubyVer}";

    inherit (pkgsMaster) claude-code;
     
    mutter = prev.mutter.overrideAttrs (oa: {
        patches = (oa.patches or []) ++ [
            ./mutter-add-fifth-scales.patch
        ];
    });

    valkey = disableCheck prev.valkey;

    nix_latest = flakes.nix.packages.${system}.nix;

    ghostty = flakes.ghostty.packages.${system}.ghostty;

    inherit (firefoxPkgs) firefox-nightly-bin;

    f3d = prev.f3d.overrideAttrs (oa: {
        buildInputs = let
            f = final;
        in oa.buildInputs ++ [
            f.opencascade-occt
            f.assimp
            f.fontconfig
        ];

        cmakeFlags = oa.cmakeFlags ++ [
            "-DF3D_PLUGIN_BUILD_OCCT=ON"
            "-DF3D_PLUGIN_BUILD_ASSIMP=ON"
        ];
    });

    libjxl-with-plugins = prev.libjxl.overrideAttrs (oa: {
        cmakeFlags = oa.cmakeFlags ++ [
            "-DJPEGXL_ENABLE_PLUGINS=ON"
        ];

        buildInputs = oa.buildInputs ++ [
            final.lcms2
        ];

        doCheck = false;
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

    discord-custom = let
        discord = final.discord.override {
            withOpenASAR = true;
            withTTS = true;
        };
    in
        final.wrapDiscord final.discord;

    wine-custom = prev.wineWow64Packages.full.override {
        wineRelease = "staging";
        gtkSupport = true;
        vaSupport = true;
        waylandSupport = true;
        embedInstallers = true;
    };

    calibre = let
        pkg = prev.calibre;

        pkgA = disableCheck pkg;
        pkgB = disableInstallCheck pkgA;

        pkgC = pkgB.overrideAttrs (oa: {
            # HACK: temp fix until nixpkgs#493988 is merged
            preInstall = ''
                export QMAKE="${final.qt6.qtbase}/bin/qmake"
            '';
        });
    in
        pkgC.override {
            speechSupport = false;
        };

    mkNamedTOML = final.formats.json {} // {
        type = let
            inherit (final.lib.types)
                oneOf bool int float str path attrsOf listOf;

            valueType = oneOf [
                bool int float str path
                (attrsOf valueType) (listOf valueType)
            ] // {
                description = "TOML value";
            };
        in valueType;

        generate = name: value:
            final.callPackage
                ({ runCommand, remarshal }:
                    runCommand name {
                        nativeBuildInputs = [ remarshal ];
                        value = builtins.toJSON value;
                        passAsFile = [ "value" ];
                    } ''
                        mkdir -p "$out"
                        json2toml "$valuePath" "$out/${name}"
                    '')
                {};
    };
}