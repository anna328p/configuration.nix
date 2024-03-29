{ pkgs, ... }:

{
    boot = {
        tmp.useTmpfs = true;
        initrd.systemd.enable = true;
    };

    # TTY appearance
    console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
    };

    environment.systemPackages = with pkgs; [
        # Misc disk tools
        multipath-tools
        hdparm

        # Disk usage viewers
        lsof

        # Partition table editors
        parted
        gptfdisk
    ];

    # Trim SSDs and sparse images
    services.fstrim.enable = true;

    programs.iotop.enable = true;
}