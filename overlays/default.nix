# root overlay, composing all of the smaller overlays here.

{ lib, flakes }:

with lib; let
	init = _: _: { inherit flakes; };
	composeOverlays = foldl composeExtensions init;

in composeOverlays (map import [
	../packages

	./misc
	./transmission
])
