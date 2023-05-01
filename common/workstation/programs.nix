{ config, lib, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		## Internet / Communications

		# Browser
		firefox-devedition-bin

		# Messengers
		discord-custom
		tdesktop
		nheko
		thunderbird

		## Creation / Editing tools

		# Text, documents
		logseq

		# Graphics
		gimp
		inkscape
		imagemagick # Conversion/editing

		# Media
		audacity # Audio editor
		ffmpeg   # Transcoding

		# Typefaces
		fontforge-gtk nodePackages.svgo

		## Programming / Software development

		# Interpreters
		nodejs
		ruby_latest
		python3

		# Nix
		nixpkgs-review
		nix-prefetch-git
		cachix

		# Misc
		gh # GitHub CLI
		direnv
		_7zz

		## Miscellaneous

		gnupg1 # Encryption
		espeak-ng # TTS
		woeusb # Write Windows install disks
		idevicerestore # Flash Apple devices

	] ++ (if config.misc.buildFull then with pkgs; [
		# Text, documents
		libreoffice

		vcv-rack # Virtual modular synth

		# Video
		zoom-us

		element-desktop 

		# VMs
		adoptopenjdk-openj9-bin-16
		mono

		# Haskell
		cabal-install
		cabal2nix
		ghc

		## Viewers / Players

		# Books
		calibre

		# Media players
		mpv_bd
		vlc_bd
		keydb

		# CAD, CAM
		openscad
		solvespace
		prusa-slicer

		# EDA
		kicad libxslt

		# Misc
		transgui

		## Compatibility tools / Emulators

		# Wine
		wine-custom
		winetricks
		samba # to provide winbind

		# Misc
		appimage-run

		anki # Flashcards
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
