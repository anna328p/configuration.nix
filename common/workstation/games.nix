{ pkgs, lib, config, ... }:

{
    environment.systemPackages = let p = pkgs; in [
        # Controller support
        p.linuxConsoleTools
    ] ++ (lib.optionals config.misc.buildFull [
        # Steam
        p.protontricks

        # Oculus Quest app store
        p.sidequest

        # Games
        p.osu-lazer
        p.wesnoth

        p.prismlauncher # Minecraft
    ]);

    # TODO: libva build broken
    programs.steam.enable = config.misc.buildFull;
}