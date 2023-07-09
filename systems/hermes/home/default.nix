{ config, pkgs, lib, ... }:

{
    imports = [
        ./dconf
        ./gtk.nix
    ];
}