{ config, lib, pkgs, ... }:

{
    options.misc.bluray = let
        inherit (lib) mkEnableOption;
    in {
        decryption.enable = mkEnableOption "Blu-ray decryption support";
    };

    config = let
        cfg = config.misc.bluray;
    in {
        nixpkgs.overlays = lib.mkIf cfg.decryption.enable [
            (final: prev: {
                mpv = prev.mpv_bd;
                mpv-unwrapped = prev.mpv-unwrapped_bd;
                vlc = prev.vlc_bd;
                ffmpeg = prev.ffmpeg_bd;
            })
        ];

        environment.systemPackages = lib.mkIf cfg.decryption.enable [
            pkgs.keydb
        ];
    };
}