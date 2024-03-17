{ config, lib, pkgs, ... }:

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

    environment = {
        systemPackages = with pkgs; [
            ## Standard utilities

            tmux
            (neovim.override { withPython3 = false; })

            moreutils # coreutils addons
            psmisc # process management tools

            eza # ls but better
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
            speedtest-cli
            wget
            nmap dnsutils whois

            # Misc
            rsync
            strace

            (nixos-rebuild.override { nix = config.nix.package.out; })
        ];

        defaultPackages = lib.mkDefault [];

        # Set default text editor
        variables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
        };

        pathsToLink = [ "/share/zsh" ];

        # local time compatibility with perlless activation / etc overlay
        # HACK: NixOS/nixpkgs#284641
        etc = lib.optionalAttrs (config.time.timeZone != null) {
            localtime.source = "/etc/zoneinfo/${config.time.timeZone}";
            localtime.mode = lib.mkForce "symlink";
        };
    };

    system.disableInstallerTools = true;

    system.etc.overlay = {
        enable = true;
        mutable = false;
    };

    programs = {
        # Shell
        zsh = {
            enable = true;
            interactiveShellInit = "bindkey -e";
            vteIntegration = true;
        };

        command-not-found.enable = false;

        less.lessopen = lib.mkDefault null;

        git.enable = true;

        nano.enable = false;
    };

    services = {
        # enable sshd everywhere
        openssh.enable = true;

        dbus.implementation = lib.mkIf config.services.dbus.enable "broker";
    };

    nix.settings = {
        experimental-features = [ "cgroups" "auto-allocate-uids" "ca-derivations" ];
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