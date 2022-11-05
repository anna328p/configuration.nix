{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		# Steam
		steam
		steam-run
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

	programs.steam.enable = true;
}
