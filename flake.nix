{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wayland.url = github:nix-community/nixpkgs-wayland;
    nur.url = github:nix-community/NUR;
  };

  outputs = { self, nixpkgs, home-manager, wayland, nur }: {
    nixosConfigurations.hermes = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModule

        ({ ... }: {
          nixpkgs.overlays = [
            wayland.overlay
            nur.overlay
          ];

          # Let 'nixos-version --json' know about the Git revision of this flake.
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
        })
      ];
    };
  };
}
