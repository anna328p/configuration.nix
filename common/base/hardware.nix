{ pkgs, ... }:

{
    boot = {
        tmp.useTmpfs = true;
        initrd.systemd.enable = true;
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