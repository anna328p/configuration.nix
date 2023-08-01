{ ... }:

final: prev: 
{
    ruby_latest = final.ruby_3_2;
    rubyPackages_latest = final.rubyPackages_3_2;

    wrapDiscord = discordPkg: final.symlinkJoin {
        name = "${discordPkg.pname}-wrapped";
        paths = [ discordPkg ];
        buildInputs = [ final.makeWrapper ];
        postBuild = ''
            wrapProgram $out/bin/${discordPkg.meta.mainProgram} \
                --add-flags "--disable-smooth-scrolling"
        '';
    };

    discord-custom = final.wrapDiscord final.discord;

    libbluray_bd = prev.libbluray.override {
        withJava = true;
        withAACS = true;
        withBDplus = true;
    };

    mpv-unwrapped_bd = prev.mpv-unwrapped.override {
        libbluray = final.libbluray_bd;
    };
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

    mkNamedTOML = final.formats.json {} // {
        type = with final.lib.types; let
            valueType = oneOf [
                bool
                int
                float
                str
                path
                (attrsOf valueType)
                (listOf valueType)
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