{ pkgs, lib, ... }:

{
	services.udev = {
		extraRules = let 
			endl = str: "${str}\n";
			dev = vid: pid: endl
				''ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="${vid}", ATTR{idProduct}=="${pid}", MODE="0664", GROUP="plugdev"'';
		in 
			# USB networking
			(endl ''KERNEL=="tun", GROUP="users", MODE="0666"'')

			# TI Calculators
			+ (lib.concatMapStrings (dev "0451") [ "e001" "e003" "e004" "e008" "e012" ])

			# GameCube Controller Adapter
			+ (dev "057e" "0337") + (dev "0456" "b672")

			# ADALM2000
			+ (dev "0451" "b672")

			# Miscellaneous
			+ (builtins.readFile "${pkgs.ddcutil}/share/ddcutil/data/45-ddcutil-i2c.rules")
			+ (builtins.readFile "${pkgs.libfido2}/etc/udev/rules.d/70-u2f.rules")
			+ (builtins.readFile "${pkgs.solaar}/etc/udev/rules.d/42-logitech-unify-permissions.rules");

		packages = with pkgs; [ gnome.gnome-settings-daemon ];
	};
}
