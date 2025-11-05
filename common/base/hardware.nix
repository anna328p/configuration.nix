{ pkgs, lib, ... }:

{
    boot = {
        tmp.useTmpfs = lib.mkDefault true;
        initrd.systemd.enable = lib.mkDefault true;
    };

    system.etc.overlay = {
        enable = lib.mkDefault true;
        mutable = lib.mkDefault false; # requires userborn
    };

    # TTY appearance
    console.keyMap = "us";

    environment.systemPackages = let p = pkgs; in [
        # Misc disk tools
        p.multipath-tools
        p.hdparm

        # Disk usage viewers
        p.lsof

        # Partition table editors
        p.parted
        p.gptfdisk
    ];

    # Trim SSDs and sparse images
    services.fstrim.enable = true;

    programs.iotop.enable = true;
}