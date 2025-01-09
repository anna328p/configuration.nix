{ pkgs, lib, config, ifFullBuild, ... }:

{
    environment.systemPackages = let p = pkgs; in [
        # Controller support
        p.linuxConsoleTools
    ] ++ (lib.optionals config.misc.buildFull [
        # Steam
        p.protontricks
        p.adwsteamgtk

        # Meta Quest app store
        p.sidequest

        # Games
        p.osu-lazer
        p.wesnoth

        p.prismlauncher # Minecraft
    ]);

    programs.steam.enable = config.misc.buildFull;
}