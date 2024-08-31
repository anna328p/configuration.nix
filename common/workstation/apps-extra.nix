{ pkgs, lib, config, ... }:

let
    isMinimal = !(config.misc.buildFull);
in {
    environment.systemPackages = let
        p = pkgs;
    in if isMinimal then [
        # Media players
        p.mpv p.vlc
    ] else [
        # Media players with Blu-Ray support
        p.mpv_bd p.vlc_bd p.keydb

        # Media creation
        p.audacity
        p.vcv-rack

        # Graphics
        p.inkscape
        p.imagemagick
        p.img2pdf

        # Text, documents
        p.libreoffice
        p.calibre
        p.xdot

        # Typefaces
        p.fontforge-gtk p.nodePackages.svgo

        # Communication
        p.zoom-us
        p.element-desktop 

        # VMs
        p.mono

        # Haskell
        p.ghc
        p.cabal-install p.cabal2nix

        # Nix
        p.nixpkgs-review

        # CAD, CAM
        p.openscad
        p.solvespace
        p.prusa-slicer
        p.f3d

        # EDA
        p.kicad p.libxslt

        # Wine
        p.wine-custom p.winetricks
        p.samba # to provide winbind

        # Misc
        p.woeusb         # Write Windows install disks
        p.idevicerestore # Flash Apple devices
        p.anki           # Flashcards
        p.gnome-decoder  # Scan QR codes from screenshots
    ];

    programs.java.enable = config.misc.buildFull;
}