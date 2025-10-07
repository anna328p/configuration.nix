{ localModules, config, lib, pkgs, ... }:

{
    imports = [
        localModules.local.misc

        ./networking.nix
        ./users.nix
        ./hardware.nix
        ./flake-support.nix
        ./machine-id.nix
    ];

    # english
    i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = [ "en_US.UTF-8/UTF-8" ];
    };

    environment = {
        systemPackages = let p = pkgs; in [
            ## Standard utilities

            p.tmux
            (p.neovim.override { withPython3 = false; })

            p.moreutils # coreutils addons
            p.psmisc # process management tools

            p.eza # ls but better
            p.tree # ls -R replacement
            p.dfc # colorful df
            p.ripgrep # faster grep -r replacement
            p.fd # easier find replacement
            p.pv # stream progress viewer

            p.jq # json query tool
            p.file # query file types
            p.bc p.units # calculators

            p.neofetch # why not?

            # Compressors, archivers
            p.zstd p.xz p.pigz
            p.zip p.unzip

            # Misc
            p.strace
            p.xxd

            (p.nixos-rebuild.override { nix = config.nix.package.out; })
        ];

        defaultPackages = lib.mkDefault [];

        # Set default text editor
        variables = rec {
            EDITOR = "nvim";
            VISUAL = EDITOR;
        };

        pathsToLink = [ "/share/zsh" ];

        etc = {
            # local time compatibility with perlless activation / etc overlay
            # HACK: NixOS/nixpkgs#284641
            localtime = lib.optionalAttrs (config.time.timeZone != null) {
                source = "/etc/zoneinfo/${config.time.timeZone}";
                mode = lib.mkForce "symlink";
            };
        };
    };

    system.disableInstallerTools = lib.mkDefault true;

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

    services.dbus.implementation = "broker";

    nix.settings = {
        experimental-features = [
            "cgroups" "auto-allocate-uids" "external-builders"
            "dynamic-derivations" "recursive-nix" "build-time-fetch-tree"
            "configurable-impure-env"
            "ca-derivations" "impure-derivations" "git-hashing" "blake3-hashes"
            "local-overlay-store" "mounted-ssh-store"
            "pipe-operators" "parallel-eval" "parse-toml-timestamps"
        ];

        auto-optimise-store = true;
        auto-allocate-uids = true;
        use-cgroups = true;

        log-lines = 50;

        use-xdg-base-directories = true;

        preallocate-contents = true;
        sync-before-registering = true;
        builders-use-substitutes = true;

        allow-import-from-derivation = true;
        lazy-trees = true;
        eval-cores = 0;

        extra-substituters = "https://nix-community.cachix.org";
        extra-trusted-public-keys =
            "nix-community.cachix.org-1"
            + ":mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    };
}