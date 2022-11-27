{ ... }:

{
	boot.kernelModules = [ "kvm-amd" ];

	services.xserver.deviceSection = ''
		Option "VariableRefresh" "true"
		Option "TearFree" "true"
	'';
}
