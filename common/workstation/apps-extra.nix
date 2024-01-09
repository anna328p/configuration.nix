{ pkgs, lib, config, ... }:

let
    isMinimal = !(config.misc.buildFull);
in {
    environment.systemPackages = with pkgs; if isMinimal then [
        # Media players
        mpv vlc
    ] else [
        # Media players with Blu-Ray support
        mpv_bd vlc_bd keydb

        # Media creation
        audacity
        vcv-rack

        # Graphics
        inkscape
        imagemagick
        img2pdf

        # Text, documents
        libreoffice
        calibre
        xdot

        # Typefaces
        fontforge-gtk nodePackages.svgo

        # Communication
        zoom-us
        element-desktop 

        # VMs
        adoptopenjdk-openj9-bin-16
        mono

        # Haskell
        ghc
        cabal-install cabal2nix

        # Nix
        nixpkgs-review

        # CAD, CAM
        openscad
        solvespace
        prusa-slicer
        f3d

        # EDA
        kicad libxslt

        # Wine
        wine-custom winetricks
        samba # to provide winbind

        # Misc
        woeusb         # Write Windows install disks
        idevicerestore # Flash Apple devices
        anki           # Flashcards
        appimage-run
    ];
}