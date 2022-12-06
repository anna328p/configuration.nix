{ pkgs, ... }:

{
	colors = pkgs.callPackage ./colors.nix { };

	tS = builtins.toString;
}
