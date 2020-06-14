self: super:
with super.lib;
let
  paths = (import <nixpkgs/nixos/lib/eval-config.nix> {
    modules = [ (import <nixos-config>) ];
  }).config.nixpkgs.overlays;
in
  foldl' (flip extends) (_: super) paths self
