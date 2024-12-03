{ self, nixpkgs, nix-on-droid, nix-prelude, nil, ... }@flakes:

let
    inherit (import ./local-modules.nix) localModules;
in rec {
    ##
    # Generic config generation

    specialArgs = let
        L = nix-prelude.lib;

        local-lib = import ./lib {
            inherit (nixpkgs) lib;
            inherit L;
        };

        overlays = [
            self.overlays.default
            nil.overlays.default
        ];
    in
        { inherit flakes overlays localModules local-lib L; };

    mkNixosSystem = modules: nixpkgs.lib.nixosSystem {
        inherit modules specialArgs;
    };

    mkAndroidEnv = modules: let
        pkgs = import nixpkgs {
            system = "aarch64-linux";
            inherit (specialArgs) overlays;
        };
    in nix-on-droid.lib.nixOnDroidConfiguration {
        inherit modules pkgs;
        extraSpecialArgs = specialArgs;
    };
}