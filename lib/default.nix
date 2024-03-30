{ lib, L, ... }@args:

L.mkLibrary args ({ using, ... }:
    using {
        options = ./options.nix;
        colors = ./colors.nix;
    } (_: {})
)