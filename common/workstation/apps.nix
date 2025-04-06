{ pkgs, flakes, system, ... }:

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
        p.difftastic

        # Misc
        p.espeak-ng # TTS
    ];

    # TODO: Remove
    nixpkgs.config.permittedInsecurePackages = [
        # Logseq 0.10 dep
        "electron-27.3.11"

        # nheko dep
        "olm-3.2.16"
    ];
}