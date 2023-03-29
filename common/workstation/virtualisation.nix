{ pkgs, ... }:

{
	virtualisation = {
		podman.enable = true;

		libvirtd = {
			enable = true;
			onShutdown = "shutdown";

			qemu.ovmf.enable = true;
			qemu.runAsRoot = false;
		};
	};

	users.users.anna.extraGroups = [ "libvirtd" ];

	environment.systemPackages = with pkgs; [
		virt-manager spice-gtk
	];
}
