{ localModules, ... }:

{
    imports = let
        inherit (localModules) common;
    in [
        common.base
        common.physical
    ];

    networking.hostName = "nixos-iso";

    services.openssh.enable = true;

    misc.uuid = "b210a256-c9d0-4c44-a658-28ce6fe204b7";

    boot.initrd.systemd.enable = false;
    system.etc.overlay.enable = false;

    system.disableInstallerTools = false;

    time.timeZone = "Etc/UTC";
}