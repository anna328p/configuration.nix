{ pkgs, ... }:

{
    environment.systemPackages = let p = pkgs; in [
        p.chirp
    ];

    misc.udev.usb.uaccessDevices = [
        # CH341 USB Serial adapter (radio programming cable)
        { vid = "1a86"; pid = "7523"; }
    ];
}