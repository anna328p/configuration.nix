{ config, pkgs, lib, flakes, ... }:

{
	imports = [
		../module

		./tmux.nix
		./shell.nix
		./git.nix
	];

	home.stateVersion = "22.05";

	manual.manpages.enable = lib.mkDefault false;
}

# vim: set ts=4 sw=4 noet :
