{ pkgs, ifFullBuild, ... }:

{
	environment.systemPackages = with pkgs; [
		# Steam
		protontricks

		# Meta Quest app store
		sidequest

		# Games
		osu-lazer
		wesnoth
		prismlauncher # Minecraft

		# Controller support
		linuxConsoleTools
	];

	programs.steam.enable = ifFullBuild true;
}
