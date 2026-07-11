{ pkgs, lib, config, ... }:

{
    programs = {
        java.enable = config.misc.buildFull;

        git.package = if config.misc.buildFull
            then pkgs.gitFull
            else pkgs.gitMinimal;
    };

    environment.systemPackages = let
        p = pkgs;

        common = [
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
            # p.binwalk # TODO: build broken 2026-06-14
            p.difftastic
        ];

        extra = [
            # VMs
            p.mono

            # Haskell
            p.ghc
            p.cabal-install p.cabal2nix

            # Nix
            p.nixpkgs-review

            # Typography
            # p.fontforge-gtk # broken
            p.svgo

            # CAD, CAM
            # p.openscad # TODO: broken 2026-06-09
            p.solvespace
            p.prusa-slicer
            # p.f3d # TODO reenable

            # EDA
            p.kicad p.libxslt

            p.claude-code
            p.codex
        ];

    in lib.mkMerge [
        common
        (lib.mkIf config.misc.buildFull extra)
    ];
}