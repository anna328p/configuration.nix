{ ... }:

{
    intransience.datastores.system = {
        etc = {
            dirs = [
                "nixos"
            ];

            files = [
                "machine-id"
            ];
        };

        byPath."/var".dirs = [
            "log"
            "opt"
        ];

        byPath."/var/lib".dirs = [
            "bluetooth"
            "cups"
            "flatpak"
            "libvirt"
            "mopidy"
            "NetworkManager"
            "zerotier-one"

            "systemd/coredump"
            "systemd/backlight"
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