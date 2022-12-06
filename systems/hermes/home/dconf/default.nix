{ lib, ... }:

{
	dconf.settings = with lib.hm.gvariant; {
		"org/gnome/settings-daemon/plugins/power".idle-dim = false;

		"org/freedesktop/tracker/miner/files" = {
			index-recursive-directories = mkArray type.string [
				"&DESKTOP" "&DOCUMENTS" "&MUSIC"
				"&PICTURES" "&VIDEOS" "&DOWNLOAD"
				"/home/anna/.wine-FL20.7/drive_c/Program Files/Image-Line/FL Studio 20/Data/Patches/Packs"
				"/home/anna/Recordings"
				"/media/storage/torrents"
				"/home/anna/work"
			];
		};
	};
}
