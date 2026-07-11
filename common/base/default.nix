{ localModules, config, lib, pkgs, flakes, ... }:

{
    imports = [
        flakes.intransience.nixosModules.default

        localModules.local.misc

        ./shell.nix
        ./networking.nix
        ./users.nix
        ./security.nix
        ./hardware.nix
        ./nix-settings.nix
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

            p.fastfetch

            # Compressors, archivers
            p.zstd p.xz p.pigz
            p.zip p.unzip

            # Misc
            p.strace
            p.xxd
        ];

        defaultPackages = lib.mkDefault [];

        # Set default text editor
        variables = rec {
            EDITOR = "nvim";
            VISUAL = EDITOR;
        };
    };

    programs = {
        git.enable = true;

        nano.enable = false;
    };

    services.dbus.implementation = "broker";
}