{ ... }:

{
	boot = {
		initrd.kernelModules = [ "zstd" ];

		kernelParams = [
			"zswap.enabled=1"
			"zswap.compressor=zstd"
		];
	};
}
