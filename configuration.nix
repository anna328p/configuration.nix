{ config, pkgs, lib, options, ... }:

{
	boot.tmpOnTmpfs = true;

	networking.enableIPv6 = true;

	i18n = {
		defaultLocale = "en_US.UTF-8";
 		supportedLocales = [ "en_US.UTF-8/UTF-8" ];
	};

	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
	};

	environment.systemPackages = with pkgs; [
		zsh tmux neovim
		exa dfc ripgrep file pv neofetch
		speedtest-cli wget
		git

		linuxConsoleTools
		zip unzip _7zz zstd xz pigz
	];

	environment.pathsToLink = [ "/share/zsh" ];

	users = {
		mutableUsers = false;
		defaultUserShell = pkgs.zsh;

		users.root.initialHashedPassword = "$6$o3HFaJySc0ptEcz$tr5ndkC9HMA0RDVobaLUncgzEiveeWtSJV8659EYdA2EnrNxB9vTrSmJVv5lAlF8nR0fu4HpBJ5e5wP02LHqq0";

		users.anna = {
			description = "Anna";
			isNormalUser = true;
			uid = 1000;

			subUidRanges = [ { startUid = 100000; count = 9999; } ];
			subGidRanges = [ { startGid = 10000; count = 999; } ];

			extraGroups = [
				"wheel" "transmission" "libvirtd"
			];

			initialHashedPassword = "$6$o3HFaJySc0ptEcz$tr5ndkC9HMA0RDVobaLUncgzEiveeWtSJV8659EYdA2EnrNxB9vTrSmJVv5lAlF8nR0fu4HpBJ5e5wP02LHqq0";
		};

		users.root = {
			hashedPassword = "$6$NxlrJrFQmV$NP4yc0wyb8LuYKApfAYpo52iorA5gDF44NmQUS21fkxVyW.PeLO14xow2l1Sa35LuwDPenQIgsD08xbCqjSgH.";
		};
	};

	services.openssh.enable = true;

	programs.zsh.enable = true;

	environment.variables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
	};

	security.sudo.wheelNeedsPassword = false;

	nixpkgs.config = {
		allowUnfree = true;
		allowBroken = true;
	};

	nix = {
		extraOptions = ''
			experimental-features = nix-command flakes ca-references ca-derivations
		'';

		package = pkgs.nixFlakes;
	};
}
# vim: noet:ts=4:sw=4:ai:mouse=a
