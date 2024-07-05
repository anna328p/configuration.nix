{ pkgs, ... }:

{
    environment.systemPackages = let p = pkgs; in [
        ## Internet / Communications

        # Browser
        p.firefox-devedition-bin

        # Password manager
        p.keepassxc

        # Messengers
        p.discord-custom
        p.tdesktop
        p.nheko
        p.thunderbird

        # Notes
        p.logseq

        # Graphics
        p.gimp

        # Media
        p.ffmpeg
        p.tremotesf

        ## Programming / Software development

        # Interpreters
        p.nodejs
        p.ruby_latest
        p.python3

        # Nix
        p.nix-prefetch-git
        p.cachix

        # Misc
        p.gh # GitHub CLI
        p.direnv
        p._7zz
        p.nix-tree
        p.binutils # strings

        # Misc
        p.espeak-ng # TTS
    ];

    # Logseq 0.10 dep
    # TODO: Remove
    nixpkgs.config.permittedInsecurePackages = [
        "electron-27.3.11"
    ];
}