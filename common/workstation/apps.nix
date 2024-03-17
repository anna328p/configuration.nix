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

        # Media
        ffmpeg
        tremotesf

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
        binutils # strings

        # Misc
        espeak-ng # TTS
    ];

    # Logseq 0.10 dep
    # TODO: Remove
    nixpkgs.config.permittedInsecurePackages = [
        "electron-25.9.0"
    ];
}