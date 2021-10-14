{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable-small;

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wayland.url = github:nix-community/nixpkgs-wayland;
    nur.url = github:nix-community/NUR;

    neovim = {
      url = github:neovim/neovim?dir=contrib;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, wayland, nur, neovim }: let
     baseSystem = extraModules: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModule

        ({ ... }: {
          home-manager = {
              users.anna = (import ./home.nix);
              useUserPackages = true;
              useGlobalPkgs = true;
          };

          nixpkgs.overlays = [ wayland.overlay nur.overlay neovim.overlay ];
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
        })
      ] ++ extraModules;
    };
  in {
    nixosConfigurations.hermes = baseSystem [];
  };
}
