{ pkgs, ... }:

{
	imports = [
		./users.nix
		./hardware.nix
		./flake-support.nix
	];

	networking = {
		enableIPv6 = true;
		domain = "ad.ap5.dev";
	};

	# english
	i18n = {
		defaultLocale = "en_US.UTF-8";
 		supportedLocales = [ "en_US.UTF-8/UTF-8" ];
	};

	environment.systemPackages = with pkgs; [
		## Standard utilities

		tmux
		neovim

		moreutils # coreutils addons
		psmisc # process management tools

		exa # ls but better
		tree # ls -R replacement
		dfc # colorful df
		ripgrep # faster grep -r replacement
		fd # easier find replacement
		pv # stream progress viewer

		jq # json query tool
		file # query file types
		bc units # calculators

		neofetch # why not?

		# Compressors, archivers
		zstd xz pigz
		zip unzip
		_7zz

		## Networking
		git
		speedtest-cli
		wget
		nmap
	];

	# Set default text editor
	environment.variables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
	};

	# Shell
	programs.zsh.enable = true;
	environment.pathsToLink = [ "/share/zsh" ];

	# enable sshd everywhere
	services.openssh.enable = true;

	# i don't really care
	nixpkgs.config = {
		allowUnfree = true;
		allowBroken = true;
	};
}
# vim: noet:ts=4:sw=4:ai:mouse=a
