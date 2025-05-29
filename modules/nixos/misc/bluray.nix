{ config, lib, pkgs, ... }:

{
    options.misc.bluray = let
        inherit (lib) mkEnableOption;
    in {
        decryption.enable = mkEnableOption "Blu-ray decryption support";
    };

    config = let
        cfg = config.misc.bluray;
        p = pkgs;
    in {
        environment.systemPackages = lib.mkIf cfg.decryption.enable (
            (map lib.hiPrio
                [ p.mpv_bd p.mpv-unwrapped_bd p.vlc_bd p.ffmpeg_bd ])
            ++ [ p.keydb ]
        );
    };
}