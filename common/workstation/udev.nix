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

            # Pinecil v1 GD32 DFU Bootloader
            { vid = "28e9"; pid = "0189"; }

            # Pinecil v2 BLIOT CDC Virtual ComPort
            { vid = "ffff"; pid = "ffff"; }
        ];

        usb.mtpNoProbe = [
            # Pinecil v1 GD32 DFU Bootloader
            { vid = "28e9"; pid = "0189"; }

            # Pinecil v2 BLIOT CDC Virtual ComPort
            { vid = "ffff"; pid = "ffff"; }
        ];

        extraRuleFiles = let
            inherit (builtins) readFile replaceStrings toFile;
            redact = str: replaceStrings [ str ] [ "" ];

            u2frules = 
                "${pkgs.libfido2}/etc/udev/rules.d/70-u2f.rules"
                |> readFile
                |> redact ''GROUP="plugdev", ''
                |> toFile "70-u2f.rules";
        in [
            u2frules
        ];

        extraRules = [
            # DDC
            ''SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"''

            # USB networking
            ''KERNEL=="tun", GROUP="users", MODE="0666"''
        ];
    };

    services.udev.packages = [ pkgs.gnome-settings-daemon ];
}