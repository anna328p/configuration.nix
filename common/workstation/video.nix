{ pkgs, config, ... }:

{
    # Virtual camera support
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModulePackages = let
        k = config.boot.kernelPackages;
    in
        [ k.v4l2loopback ];

    environment.systemPackages = [
        # Webcam viewer
        pkgs.guvcview
    ];

    # Allow webcam access (not sure if this is useful)
    users.users.anna.extraGroups = [ "video" ];

    # Hardware video decoding
    hardware.graphics.extraPackages = let p = pkgs; in [
        p.libva1 p.libva-vdpau-driver p.libvdpau-va-gl
    ];
}