{ pkgs, ... }:

{
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

    environment.systemPackages = [ pkgs.mpdris2 ];

    systemd.user.services.mpdris2 = {
        description = "MPRIS2 support for MPD";
        serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            ExecStart = "${pkgs.mpdris2}/bin/mpDris2";
        };
    };
}