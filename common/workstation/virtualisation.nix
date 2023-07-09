{ config, pkgs, ... }:

{
    virtualisation = {
        podman.enable = true;

        libvirtd = {
            enable = true;
            onShutdown = "shutdown";

            qemu = {
                ovmf.enable = true;
                runAsRoot = false;

                package = if config.misc.buildFull
                    then pkgs.qemu
                    else pkgs.qemu_kvm;
            };
        };
    };

    users.users.anna.extraGroups = [ "libvirtd" ];

    environment.systemPackages = with pkgs; [
        virt-manager spice-gtk
    ];
}
