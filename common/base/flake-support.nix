{ pkgs, flakes, ... }:

{
	nix = {
		extraOptions = ''
			experimental-features = nix-command flakes repl-flake
		'';

		package = pkgs.nixVersions.unstable;

		registry.nixpkgs.flake = flakes.nixpkgs;

		nixPath = [
			"nixpkgs=${flakes.nixpkgs}"
			"nixos=${flakes.nixpkgs}"
		];
	};

	system.configurationRevision = flakes.nixpkgs.lib.mkIf (flakes.self ? rev) flakes.self.rev;
}
