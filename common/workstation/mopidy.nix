{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		mpdris2
	];

	services = {
		mopidy = {
			# enable = true; # broken
			extensionPackages = with pkgs; [
				mopidy-mpd mopidy-iris mopidy-scrobbler
				mopidy-ytmusic mopidy-somafm
			];

			configuration = builtins.readFile files/mopidy.conf;
		};
	};

	systemd.user.services.mpdris2 = {
		description = "MPRIS2 support for MPD";
		serviceConfig = {
			Type = "simple";
			Restart = "on-failure";
			ExecStart = "${pkgs.mpdris2}/bin/mpDris2";
		};
	};
}
