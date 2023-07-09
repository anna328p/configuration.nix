{ config, lib, pkgs, ... }:

{
    # flatpak
    services.flatpak.enable = true;

    # gpg agent
    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
    };
}
