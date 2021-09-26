{ config, lib, pkgs, ... }:
let
  rev = "master";
  # 'rev' could be a git rev, to pin the overla.
  # if you pin, you should use a tool like `niv` maybe, but please consider trying flakes
  url = "https://github.com/nix-community/nixpkgs-wayland/archive/${rev}.tar.gz";
  waylandOverlay = (import (builtins.fetchTarball url));
in
  {
    nixpkgs.overlays = [ waylandOverlay ];
  }
