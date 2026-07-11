{ pkgs, lib, config, ... }:

{
    environment.systemPackages = let
        p = pkgs;
    in lib.mkIf config.misc.buildFull [
        # Graphics
        p.inkscape
        p.imagemagick
        p.img2pdf
        p.darktable

        # Text, documents
        p.calibre

        # Communication
        p.zoom-us
        #p.element-desktop  # build broken 2025-10-11

        # Wine
        p.wine-custom p.winetricks
        p.samba # to provide winbind

        # Misc
        p.woeusb         # Write Windows install disks
        # p.idevicerestore # Flash Apple devices (build broken)
        p.anki           # Flashcards
        p.gnome-decoder  # Scan QR codes from screenshots
    ];
}