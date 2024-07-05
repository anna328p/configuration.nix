{ lib, pkgs, config, flakes, overlays, ... }:

{
    nixpkgs = {
        inherit overlays;

        config.allowUnfree = true;
        config.allowBroken = true;
    };

    _module.args.pkgsMaster = let
        build = config.nixpkgs.buildPlatform;
        host = config.nixpkgs.hostPlatform;
        isCrossBuild = build != host;

        systemArgs = if isCrossBuild
            then { localSystem = build; crossSystem = host; }
            else { localSystem = host; };

        args = { inherit (pkgs) config overlays; };

    in import flakes.nixpkgs-master (args // systemArgs);

    nix = {
        settings.experimental-features = [
            "nix-command" "flakes"
        ];

        package = pkgs.nixVersions.latest;

        registry.nixpkgs.flake = flakes.nixpkgs;

        nixPath = [
            "nixpkgs=${flakes.nixpkgs}"
            "nixos=${flakes.nixpkgs}"
        ];
    };

    system.configurationRevision = lib.mkIf (flakes.self ? rev) flakes.self.rev;
}