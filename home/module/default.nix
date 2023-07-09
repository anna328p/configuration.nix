{ config, lib, L, ... }:

with lib; with L; let
    cfg = config.misc;
in {
    imports = [
        ./fonts.nix
        ./bookmarks.nix
    ];
}
