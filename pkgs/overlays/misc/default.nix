{ flakes, mkFlakeVer, ... }:

final: prev: 
{
    # inherit (flakes.neovim.packages.${final.system}) neovim;
    neovim = prev.neovim.override { withRuby = false; };

    inherit (flakes.nixd.packages.${final.system}) nixd;

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
}
