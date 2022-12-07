{ pkgs, lib, ... }:

{
	colors = pkgs.callPackage ./colors.nix { };

	fontCss = opt: let
		sizeStr = builtins.toString opt.size;
	in "${sizeStr}pt ${opt.name}";

	urlencode = import ./urlencode.nix lib;
}
