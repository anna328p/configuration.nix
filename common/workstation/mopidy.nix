{ config, lib, pkgs, ... }:

{
    options = {
        services.mpdris2 = {
            enable = lib.mkEnableOption "MPRIS2 support for MPD";
        };
    };

    config = let
        mcfg = config.services.mpdris2;
    in {
        services = {
            mopidy = {
                # enable = true; # broken
                extensionPackages = let p = pkgs; in [
                    p.mopidy-mpd p.mopidy-iris p.mopidy-scrobbler
                    p.mopidy-ytmusic p.mopidy-somafm
                ];

                configuration = builtins.readFile files/mopidy.conf;
            };
        };

        environment.systemPackages = lib.mkIf mcfg.enable [ pkgs.mpdris2 ];

        systemd.user.services.mpdris2 = lib.mkIf mcfg.enable {
            description = "MPRIS2 support for MPD";
            serviceConfig = {
                Type = "simple";
                Restart = "on-failure";
                ExecStart = "${pkgs.mpdris2}/bin/mpDris2";
            };
        };
    };
}