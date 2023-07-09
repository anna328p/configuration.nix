{ ... }:

{
    environment.persistence."/safe/system" = {
        directories = [
            "/etc/nixos"

            "/etc/mullvad-vpn"
            "/etc/NetworkManager/system-connections"
            "/etc/ssh"

            "/var/log"
            "/var/cache/powertop"

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
}