{ ... }:

final: prev: {
    libbluray_bd = prev.libbluray.override {
        # TODO: NixOS/nixpkgs#296748
        # withJava = true;

        withAACS = true;
        withBDplus = true;
    };

    mpv = prev.mpv.override {
        scripts = [ final.mpvScripts.mpris ];
    };

    mpv-unwrapped_bd = prev.mpv-unwrapped.override {
        libbluray = final.libbluray_bd;
    };

    mpv_bd = final.mpv-unwrapped.wrapper {
        mpv = final.mpv-unwrapped_bd;
        scripts = [ final.mpvScripts.mpris ];
    };

    vlc_bd = prev.vlc.override { libbluray = final.libbluray_bd; };
}