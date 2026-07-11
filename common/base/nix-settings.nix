{ pkgs, config, lib, ... }:

{
    environment.systemPackages = let
        p = pkgs;
        nixos-rebuild = config.system.build.nixos-rebuild;
    in [
        nixos-rebuild
        p.nh
    ];

    system.disableInstallerTools = lib.mkDefault true;

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

        substituters = [
            "https://nix-community.cachix.org"
            "https://anna328p.cachix.org"
            "https://install.determinate.systems"
        ];

        trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "anna328p.cachix.org-1:HcPUMrtQ7qT+bfx2fQ2HyJV5wCYQ2A3WwhxxrxDkvG0="
            "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        ];
    };
}