# root overlay, composing all of the smaller overlays here.

{ lib, pkgs, ... }@args:

with lib; let
	composeOverlays = foldl composeExtensions (final: prev: {});
	callList = map (a: pkgs.callPackage a args);
in {
	overlay = composeOverlays (callList [
		../packages

		./misc
		./transmission
	]);
}
