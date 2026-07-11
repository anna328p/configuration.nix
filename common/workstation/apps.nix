{ pkgs, ... }:

{
    environment.systemPackages = let p = pkgs; in [
        p.clockify

        ## Internet / Communications

        # Browser
        p.firefox-nightly-bin

        # Password manager
        p.keepassxc

        # Messengers
        p.discord-custom
        p.telegram-desktop
        p.nheko
        p.thunderbird
        p.signal-desktop

        # Notes
        p.logseq
        p.anytype

        # Graphics
        p.gimp3
        p.darktable

        p.graphviz

        # Media
        p.tremotesf

        # Media players
        p.mpv p.vlc
        p.ffmpeg

        # Documents
        p.libreoffice-fresh

        # Misc
        p.espeak-ng # TTS
    ];

    # TODO: Remove
    nixpkgs.config.permittedInsecurePackages = [
        # nheko dep
        "olm-3.2.16"

        # logseq dep
        "electron-39.8.10"
    ];
}