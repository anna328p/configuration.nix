{ ... }:

{
	environment.persistence."/persist" = {
		directories = [
			"/etc/ssh"
			"/var/log"
			"/var/lib/bluetooth"
			"/var/lib/systemd/coredump"
			"/etc/NetworkManager/system-connections"
			"/var/lib/mopidy"
			"/var/cache/powertop"
		];
		files = [
			"/etc/machine-id"
		];
	};
}
# vim: noet:ts=4:sw=4:ai:mouse=a
