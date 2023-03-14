{ ... }:

{
	imports = [
		./udev.nix
		./hw-support.nix
		./networking.nix
		./docs.nix

		./kmscon.nix

		./sound.nix
		./video.nix
		./gui.nix

		./mopidy.nix
		./games.nix
		./programs.nix
	];

	boot = {
		plymouth.enable = true;

		kernelParams = [ "iomem=relaxed" "mitigations=off" ];
	};

	# Import home configs
	home-manager = {
		users.anna.imports = [ ../home/workstation ];
	};

	# Don't interfere with home-manager's zsh config
	programs.zsh.promptInit = "";
}
# vim: noet:ts=4:sw=4:ai:mouse=a
