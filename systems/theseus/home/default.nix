{ config, pkgs, lib, ... }:

{
	imports = [
		../../../common/home
		./dconf
		./gtk.nix
	];
}

# vim: set ts=4 sw=4 noet :
