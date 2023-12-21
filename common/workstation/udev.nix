{ pkgs, ... }:

{
    misc.udev = {
        enable = true;

        usb.uaccessDevices = [
            # TI Calculators
            { vid = "0451"; pid = [ "e001" "e003" "e004" "e008" "e012" ]; }
            
            # GameCube Controller Adapter
            { vid = "057e"; pid = "0337"; }
            { vid = "0456"; pid = "b672"; }

            # ADALM2000
            { vid = "0451"; pid = "b672"; }
        ];

        extraRuleFiles = [
            "${pkgs.libfido2}/etc/udev/rules.d/70-u2f.rules"
        ];

        extraRules = [
            # DDC
            ''SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"''

            # USB networking
            ''KERNEL=="tun", GROUP="users", MODE="0666"''
        ];
    };

    services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
}