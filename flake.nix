{
  description = "NixOS system configuration";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.hermes = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ''
          # Let 'nixos-version --json' know about the Git revision of this flake.
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
        ''
      ];
    };
  };
}
