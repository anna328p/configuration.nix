{ lib, ... }:

{
    dconf.settings = let
        inherit (lib.hm.gvariant)
            mkUint32
            mkArray
            ;

    in {
        "org/gnome/settings-daemon/plugins/power".idle-dim = false;

        "org/gnome/desktop/session".idle-delay = mkUint32 0;

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