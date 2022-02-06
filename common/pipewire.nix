{ ... }:

{
	services.pipewire = {
		enable = true;
		pulse.enable = true;
		jack.enable = true;

		media-session = {
			enable = true;

			config.alsa-monitor = {
				properties = {
					"api.alsa.period-size" = 6;
					"api.alsa.disable-batch" = true;
				};
			};
		};

		alsa = {
			enable = true;
			support32Bit = true;
		};

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

				{ name = "libpipewire-module-protocol-pulse";
				  args = { "server.address" = [ "unix:native" "tcp:4713" ];
						   "vm.overrides"   = { "pulse.min.quantum" = "1024/48000"; }; }; }
			];
		};
	};
}
