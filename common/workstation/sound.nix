{ pkgs, ... }:

{
	# MIDI support
	boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];

	# hardware stuff?
	sound.enable = true;

	# Manage audio server stuff
	environment.systemPackages = with pkgs; [
		pavucontrol
		# helvum # TODO: broken 2023-01-19 https://github.com/NixOS/nixpkgs/issues/211610
	];

	# Allow audio access (I have no idea if this does anything)
	users.users.anna.extraGroups = [ "audio" "jackaudio" ];

	# Build packages with PulseAudio support...
	nixpkgs.config.pulseaudio = true;

	# ...but disable PulseAudio...
	hardware.pulseaudio.enable = false;

	# ...and use PipeWire instead!
	services.pipewire = {
		enable = true;

		# All the compatibility layers
		pulse.enable = true;
		jack.enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;

		# Modern session manager
		media-session.enable = false;
		wireplumber.enable = true;

		# Latency tweaks
		config.pipewire = {
			"context.properties.default.clock" = {
				quantum = 32;
				min-quantum = 32;
				max-quantum = 8192;
			};
		};

		config.pipewire-pulse = {
			"context.modules" = [
				{ name = "libpipewire-module-protocol-native"; }
				{ name = "libpipewire-module-client-node"; }
				{ name = "libpipewire-module-adapter"; }
				{ name = "libpipewire-module-metadata"; }

				{ name = "libpipewire-module-rtkit";
				  flags = [ "ifexists" "nofail" ]; }

				# Allow network access and fix crackling
				{ name = "libpipewire-module-protocol-pulse";
				  args = { "server.address" = [ "unix:native" "tcp:4713" ];
						   "vm.overrides"   = { "pulse.min.quantum" = "1024/48000"; }; }; }
			];
		};
	};

	# Allow pipewire to run with realtime priority to reduce audio latency
	security = {
		pam.loginLimits = [
			{ domain = "@audio"; type = "-"; item = "nice"; value = "-20"; }
			{ domain = "@audio"; type = "-"; item = "rtprio"; value = "99"; }
		];

		rtkit.enable = true;
	};
}
