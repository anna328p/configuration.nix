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

    pkgsUnstable = flakes.nixpkgs-unstable.legacyPackages.${system};
in {
    ruby_latest = final."ruby_${rubyVer}";
    rubyPackages_latest = final."rubyPackages_${rubyVer}";
     
    # inherit (pkgsUnstable) tdesktop;

    mutter = prev.mutter.overrideAttrs (oa: {
        src = flakes.mutter;

        postUnpack = ''
            pushd source/subprojects
            ln -s ${flakes.gvdb} gvdb
            popd
        '';
    });

        # git = prev.git.override {
        #     doInstallCheck = false;
        # };

        # gitMinimal = prev.gitMinimal.override {
        #     doInstallCheck = false;
        # };

        # colord = prev.colord.overrideAttrs (oa: {
        #     doInstallCheck = false;
        # });

        # openldap = prev.openldap.overrideAttrs (oa: {
        #     doCheck = false;
        # });

        # libphonenumber = prev.libphonenumber.override {
        #     enableTests = false;
        # };

        # nbd = prev.nbd.overrideAttrs (oa: {
        #     doCheck = false;
        # });

        # dfc = prev.dfc.overrideAttrs (oa: {
        #     doCheck = false;
        #     cmakeFlags = (oa.cmakeFlags or []) ++ [
        #         "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
        #     ];
        # });

        # maxflow = prev.maxflow.overrideAttrs (oa: {
        #     doCheck = false;
        #     cmakeFlags = (oa.cmakeFlags or []) ++ [
        #         "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
        #     ];
        # });

        # libvdpau-va-gl = overrideCmake prev.libvdpau-va-gl;

        # neovim-unwrapped = prev.neovim-unwrapped.override {
        #     lua = final.luajit_2_1.override {
        #         packageOverrides = lfinal: lprev: {
        #             rustaceanvim = disableCheck lprev.rustaceanvim;
        #         };
        #     };
        # };

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

    calibre = let
        pkg = prev.calibre.overrideAttrs (oa: {
            buildInputs = oa.buildInputs ++ [ final.python3Packages.pycryptodome ];
            doCheck = false;
            doInstallCheck = false;
        });
    in
        pkg.override {
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