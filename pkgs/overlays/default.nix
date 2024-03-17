# root overlay, composing all of the smaller overlays here.

{ lib, flakes, mkFlakeVer, ... }:

with lib; let
    init = _: _: { };
    composeOverlays = foldl composeExtensions init;


    replaceBuildInputs = oldInputs: toRemove: toAdd: let
        subtracted = subtractLists toRemove oldInputs;
    in
        subtracted ++ toAdd;


    importArgs = {
        inherit flakes mkFlakeVer replaceBuildInputs;
    };

    importOverlay = p: import p importArgs;

in composeOverlays (map importOverlay [
    ../overlay.nix

    ./misc
    ./transmission
    ./vim
    ./bluray
])