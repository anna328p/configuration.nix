{ ... }:

{
    intransience.datastores.system = {
        etc = {
            dirs = [
                "nixos"
                "colord"
            ];

            files = [
                "machine-id"
                "zfs/zpool.cache"
                "wpa_supplicant/imperative.conf"
            ];
        };

        byPath."/var".dirs = [
            "log"
            "opt"
        ];

        byPath."/var/lib".dirs = [
            "alsa"
            "bluetooth"
            "cups"
            "flatpak"
            "libvirt"
            "mopidy"
            "NetworkManager"
            "nixos"
            "systemd"
            "zerotier-one"
        ];
    };

    intransience.datastores.cache = {
        byPath."/var/cache".dirs = [
            "cups"
            "fwupd"
            "powertop"
        ];
    };
}