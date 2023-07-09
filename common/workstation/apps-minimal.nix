{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        ## Internet / Communications

        # Browser
        firefox-devedition-bin

        # Messengers
        discord-custom
        tdesktop
        nheko
        thunderbird

        # Notes
        logseq

        # Graphics
        gimp
        inkscape
        imagemagick
        img2pdf

        # Media
        ffmpeg

        ## Programming / Software development

        # Interpreters
        nodejs
        ruby_latest
        python3

        # Nix
        nix-prefetch-git
        cachix

        # Misc
        gh # GitHub CLI
        direnv
        _7zz
        nix-tree

        # Misc
        espeak-ng # TTS
    ];
}
