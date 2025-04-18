{ flakes, mkFlakeVer, ... }:

final: prev: let
    rubyVer = "3_4";

    # nixpkgs-24_11 = flakes.nixpkgs-24_11.legacyPackages.${final.system};

    nixpkgs-ufr2 = import flakes.nixpkgs-ufr2 {
        inherit (final) system;
        config.allowUnfree = true;
    };

in {
    ruby_latest = final."ruby_${rubyVer}";
    rubyPackages_latest = final."rubyPackages_${rubyVer}";

    mutter = prev.mutter.overrideAttrs (oa: {
        patches = (oa.patches or []) ++ [
            ./0001-add-hack-for-monitor-scaling.patch
        ];
    });

    inherit (nixpkgs-ufr2) canon-cups-ufr2;

    nix_latest = flakes.nix.packages.${final.system}.nix;

    ghostty = flakes.ghostty.packages.${final.system}.ghostty;

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

    wine-custom = prev.wineWowPackages.full.override {
        wineRelease = "staging";
        gtkSupport = true;
        vaSupport = true;
        waylandSupport = true;
        embedInstallers = true;
    };

    calibre = prev.calibre.overrideAttrs (oa: {
        buildInputs = oa.buildInputs ++ [ final.python3Packages.pycryptodome ];
        doCheck = false;
        doInstallCheck = false;
    });

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