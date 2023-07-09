{ pkgs, config, ... }:

{
    # Virtual camera support
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

    environment.systemPackages = with pkgs; [
        # Webcam viewer
        guvcview
    ];

    # Allow webcam access (not sure if this is useful)
    users.users.anna.extraGroups = [ "video" ];

    # Hardware video decoding
    hardware.opengl.extraPackages = with pkgs; [ libva1 vaapiVdpau libvdpau-va-gl ];
}
