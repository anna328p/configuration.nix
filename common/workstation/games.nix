{ pkgs, lib, config, ifFullBuild, ... }:

{
    environment.systemPackages = with pkgs; [
        # Controller support
        linuxConsoleTools
    ] ++ (lib.optionals config.misc.buildFull (with pkgs; [
        # Steam
        protontricks

        # Meta Quest app store
        sidequest

        # Games
        osu-lazer
        wesnoth
        # TODO: reenable when nixpkgs#229358 fixed
        # prismlauncher # Minecraft
    ]));

    programs.steam.enable = config.misc.buildFull;
}
