{ config, pkgs, lib, options, flakes, ... }:

{
	boot.tmpOnTmpfs = true;

	networking = {
		enableIPv6 = true;
		domain = "ad.ap5.dev";
	};

	i18n = {
		defaultLocale = "en_US.UTF-8";
 		supportedLocales = [ "en_US.UTF-8/UTF-8" ];
	};

	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
	};

	environment.systemPackages = with pkgs; [
		linuxConsoleTools
		zsh tmux neovim
		exa dfc ripgrep file pv neofetch units bc
		zip unzip _7zz zstd xz pigz

		speedtest-cli wget nmap git
	];

	environment.pathsToLink = [ "/share/zsh" ];

	users = {
		mutableUsers = false;
		defaultUserShell = pkgs.zsh;

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

		users.root.initialHashedPassword = "$6$o3HFaJySc0ptEcz$tr5ndkC9HMA0RDVobaLUncgzEiveeWtSJV8659EYdA2EnrNxB9vTrSmJVv5lAlF8nR0fu4HpBJ5e5wP02LHqq0";
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
			experimental-features = nix-command flakes
		'';

		package = pkgs.nixFlakes;

		registry.nixpkgs.flake = flakes.nixpkgs;

		nixPath = [
			"nixpkgs=${flakes.nixpkgs}"
			"nixos=${flakes.nixpkgs}"
		];
	};

	system.configurationRevision = flakes.nixpkgs.lib.mkIf (flakes.self ? rev) flakes.self.rev;
}
# vim: noet:ts=4:sw=4:ai:mouse=a
