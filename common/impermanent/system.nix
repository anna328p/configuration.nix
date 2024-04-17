{ ... }:

{
    environment.persistence.system = {
        directories = [
            "/etc/nixos"

            "/etc/ssh"

            "/var/log"

            "/var/opt"

            "/var/lib/bluetooth"
            "/var/lib/cups"
            "/var/lib/flatpak"
            "/var/lib/libvirt"
            "/var/lib/mopidy"
            "/var/lib/NetworkManager"
            "/var/lib/zerotier-one"

            "/var/lib/systemd/coredump"
            "/var/lib/systemd/backlight"
        ];
        files = [
            "/etc/machine-id"
        ];
    };

    environment.persistence.cache = {
        directories = [
            "/var/cache/cups"
            "/var/cache/fwupd"
            "/var/cache/powertop"
        ];
    };
}