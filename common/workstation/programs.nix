{ config, lib, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		## Internet / Communications

		# Browser
		firefox-devedition-bin

		# Messengers
		discord-custom
		tdesktop
		element-desktop nheko
		thunderbird

		# Video
		zoom-us

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

		# Misc
		gh # GitHub CLI
		direnv
		_7zz

		## Compatibility tools / Emulators

		# Misc
		appimage-run

		## Miscellaneous

		anki # Flashcards
		gnupg1 # Encryption
		espeak-ng # TTS
		woeusb # Write Windows install disks
		idevicerestore # Flash Apple devices

	] ++ (if config.misc.buildFull then with pkgs; [
		# Wine
		wine-custom
		winetricks

		# Media players
		mpv_bd
		vlc_bd
		keydb

		# Misc
		transgui
	] else with pkgs; [
		# Media players
		mpv
		vlc
	]);

	# flatpak
	services.flatpak.enable = true;

	# gpg agent
	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};
}
