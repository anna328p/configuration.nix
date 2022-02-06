{ pkgs }:

{

	extraRules = ''
		# GameCube Controller Adapter
		SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
		SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b672", MODE="0666"

		KERNEL=="tun", GROUP="users", MODE="0666"

		# TI Calculators
		ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e001", MODE="0666", GROUP="plugdev"
		ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e003", MODE="0666", GROUP="plugdev"
		ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e004", MODE="0666", GROUP="plugdev"
		ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e008", MODE="0666", GROUP="plugdev"
		ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e012", MODE="0666", GROUP="plugdev"
		KERNEL=="tun", GROUP="users", MODE="0660"

		# ADALM2000
		ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0456", ATTR{idProduct}=="b672", MODE="0666", group="plugdev"
	''
		+ (builtins.readFile "${pkgs.ddcutil}/share/ddcutil/data/45-ddcutil-i2c.rules")
		+ (builtins.readFile "${pkgs.libfido2}/etc/udev/rules.d/70-u2f.rules")
		+ (builtins.readFile "${pkgs.solaar}/etc/udev/rules.d/42-logitech-unify-permissions.rules");

	packages = with pkgs; [ gnome.gnome-settings-daemon ];
}
