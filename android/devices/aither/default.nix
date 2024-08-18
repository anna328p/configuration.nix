{ lib, L, pkgs, config, localModules, specialArgs, ... }:

{
    environment.packages = let p = pkgs; in [
        p.neovim
        p.elinks
        p.curl
        p.wget
        p.ruby_3_2
        p.openssh
        p.git
        p.file
        p.eza
        p.fd
        p.ripgrep
        p.tmux

        p.diffutils
        p.findutils
        p.utillinux
        p.tzdata
        p.hostname
        p.man
        p.gnugrep
        p.gnused
        p.gnutar
        p.gzip
        p.zip
        p.unzip

        (p.python3.withPackages (py: [
            py.requests
            py.flask
            py.beautifulsoup4
            py.transformers
            py.openai
            py.anthropic
            py.torch
            py.psutil
        ]))

        p.procps  # Added procps
        p.imagemagick  # Added ImageMagick
    ];

    environment.sessionVariables = rec {
        EDITOR = "nvim";
        VISUAL = EDITOR;
    };

    android-integration = {
        am.enable = true;
        termux-open.enable = true;
        termux-open-url.enable = true;
        termux-reload-settings.enable = true;
        termux-setup-storage.enable = true;
        termux-wake-lock.enable = true;
        termux-wake-unlock.enable = true;
        xdg-open.enable = true;
        unsupported.enable = true;
    };

    home-manager = {
        useGlobalPkgs = true;

        extraSpecialArgs = specialArgs;

        sharedModules = [ localModules.home.base ];

        backupFileExtension = "hm-backup";

        config = { };
    };

    terminal.colors = let
        witchhazel = import
            "${localModules.home.workstation}/theming/witchhazel.nix"
            { inherit lib; };
        
        inherit (witchhazel.colorScheme) palette;
        c = L.mapAttrValues (v: "#${v}") palette;
    in {
        background = c.base00;
        foreground = c.base05;
        cursor = c.base05;

        color0  = c.base00; color1  = c.base08;
        color2  = c.base0B; color3  = c.base0A;
        color4  = c.base0D; color5  = c.base0E;
        color6  = c.base0C; color7  = c.base05;

        color8  = c.base03; color9  = c.base08;
        color10 = c.base0B; color11 = c.base0A;
        color12 = c.base0D; color13 = c.base0E;
        color14 = c.base0C; color15 = c.base07;
    };

    terminal.font =
        "${pkgs.source-code-pro}/share/fonts/opentype/SourceCodePro-Regular.otf";

    time.timeZone = "America/Chicago";

    nix.extraOptions = ''
        experimental-features = nix-command flakes ca-derivations
    '';

    # Backup etc files instead of failing to activate generation if a file already exists in /etc
    environment.etcBackupExtension = ".bak";

    # Read the changelog before changing this value
    system.stateVersion = "22.05";

}