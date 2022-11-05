# root overlay, composing all of the smaller overlays here.

{ lib }:

with lib; {
	overlay = foldl
		composeExtensions
		(self: super: {})
		(map import [
			./misc
			./transmission
		]);
}
