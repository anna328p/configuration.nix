{ pkgs, lib, config, ... }:

{
    environment.systemPackages = let
        p = pkgs;
    in lib.mkIf config.misc.buildFull [
        # Media creation
        p.audacity
        p.vcv-rack

        # Graphics
        p.inkscape
        p.imagemagick
        p.img2pdf
        p.darktable

        # Text, documents
        p.calibre

        # Typefaces
        p.fontforge-gtk p.nodePackages.svgo

        # Communication
        p.zoom-us
        #p.element-desktop  # build broken 2025-10-11

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
        # p.f3d # TODO reenable

        # EDA
        p.kicad p.libxslt

        # Wine
        p.wine-custom p.winetricks
        p.samba # to provide winbind

        # Misc
        p.woeusb         # Write Windows install disks
        # p.idevicerestore # Flash Apple devices (build broken)
        p.anki           # Flashcards
        p.gnome-decoder  # Scan QR codes from screenshots
    ];

    programs.java.enable = config.misc.buildFull;
}