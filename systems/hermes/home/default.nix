{ config, pkgs, lib, ... }:

{
	imports = [
		../../../common/home
		./dconf.nix
	];
}

# vim: set ts=4 sw=4 noet :
