{ pkgs, ... }:

{
    imports = [
        ../module

        ./users.nix
        ./hardware.nix
        ./flake-support.nix
    ];

    networking = {
        enableIPv6 = true;
        domain = "lan.ap5.network";
    };

    # english
    i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = [ "en_US.UTF-8/UTF-8" ];
    };

    environment.systemPackages = with pkgs; [
        ## Standard utilities

        tmux
        neovim

        moreutils # coreutils addons
        psmisc # process management tools

        exa # ls but better
        tree # ls -R replacement
        dfc # colorful df
        ripgrep # faster grep -r replacement
        fd # easier find replacement
        pv # stream progress viewer

        jq # json query tool
        file # query file types
        bc units # calculators

        neofetch # why not?

        # Compressors, archivers
        zstd xz pigz
        zip unzip

        ## Networking
        git
        speedtest-cli
        wget
        nmap dnsutils whois
    ];

    # Set default text editor
    environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
    };

    # Shell
    programs.zsh = {
        enable = true;
        interactiveShellInit = "bindkey -e";
    };

    environment.pathsToLink = [ "/share/zsh" ];

    # enable sshd everywhere
    services.openssh.enable = true;

    nix.settings = {
        experimental-features = [ "cgroups" "auto-allocate-uids" ];
        auto-optimise-store = true;
        auto-allocate-uids = true;
        use-cgroups = true;
        preallocate-contents = true;
        allow-import-from-derivation = true;

        extra-substituters = "https://nix-community.cachix.org";
        extra-trusted-public-keys =
            "nix-community.cachix.org-1"
            + ":mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    };
}