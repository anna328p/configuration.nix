{ lib, pkgs, config, flakes, overlays, ... }:

let
    inherit (pkgs.stdenv.hostPlatform) system;
in {
    nixpkgs = {
        inherit overlays;
        config.allowUnfree = true;
        config.allowBroken = true;
    };

    _module.args.pkgsMaster = let
        inherit (config.nixpkgs) buildPlatform hostPlatform;

        isCrossBuild = buildPlatform != hostPlatform;

        systemArgs = if isCrossBuild
            then { localSystem = buildPlatform; crossSystem = hostPlatform; }
            else { localSystem = hostPlatform; };

        args = { inherit (pkgs) config overlays; };

    in import flakes.nixpkgs-master (args // systemArgs);

    nix = {
        settings.experimental-features = [
            "nix-command" "flakes"
        ];

        package = flakes.nix.packages.${system}.nix;

        # BUG: older nix fails to load the flake if lastModified is set
        registry.nixpkgs.flake =
            lib.removeAttrs flakes.nixpkgs [ "lastModified" ];

        nixPath = [
            "nixpkgs=${flakes.nixpkgs}"
            "nixos=${flakes.nixpkgs}"
        ];
    };

    system.configurationRevision = lib.mkIf (flakes.self ? rev) flakes.self.rev;
}