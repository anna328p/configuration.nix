{ pkgs, pkgsMaster, ... }:

{
	environment.systemPackages = with pkgs; [
		## Internet / Communications

		# Browser
		firefox-devedition-bin

		# Messengers
		tdesktop
		element-desktop nheko

		# Video
		zoom-us

		# Misc
		transgui

		## Creation / Editing tools

		# Text, documents
		libreoffice
		logseq

		# CAD, CAM
		openscad
		solvespace
		prusa-slicer

		# EDA
		kicad libxslt

		# Graphics
		gimp
		inkscape
		krita
		imagemagick # Conversion/editing

		# Media
		audacity # Audio editor
		kdenlive # Video editor
		# vcv-rack # Virtual modular synth; expensive to build
		ffmpeg   # Transcoding

		# Typefaces
		fontforge-gtk nodePackages.svgo

		## Viewers / Players

		# Media players
		mpv
		vlc

		# Books
		calibre

		## Programming / Software development

		# Interpreters
		nodejs
		ruby_3_1
		python3

		# VMs
		adoptopenjdk-openj9-bin-16
		mono

		# Haskell
		cabal-install
		cabal2nix
		ghc

		# Nix
		nixpkgs-review
		nix-prefetch-git
		cachix

		# VMs
		virtmanager spice-gtk

		# Misc
		gh # GitHub CLI
		direnv

		## Compatibility tools / Emulators

		# Wine
		myWine
		winetricks

		# Misc
		appimage-run

		## Miscellaneous

		anki # Flashcards
		gnupg1 # Encryption
		espeak-ng # TTS
		woeusb # Write Windows install disks
	];

	# flatpak
	services.flatpak.enable = true;

	# gpg agent
	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};
}
