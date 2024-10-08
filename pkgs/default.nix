{ flakes }:

let
    inherit (flakes) nixpkgs;

    truncateRev = builtins.substring 0 7;

    mkFlakeVer = flake: prefix:
        "${prefix}-rev-${truncateRev flake.rev}";
in {
    overlays.default = import ./overlays {
        inherit (nixpkgs) lib;
        inherit flakes mkFlakeVer;
    };

    mkPackageSet = pkgs: import ./all-packages.nix {
        inherit (pkgs) callPackage;
        inherit flakes mkFlakeVer;
    };
}