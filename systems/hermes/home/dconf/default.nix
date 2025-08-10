{ lib, ... }:

{
    dconf.settings = {
        "org/gnome/settings-daemon/plugins/power".idle-dim = true;

        "org/gnome/mutter".experimental-features = [
            "scale-monitor-framebuffer"
            "variable-refresh-rate"
            "xwayland-native-scaling"
        ];

        "org/gnome/desktop/interface" = {
            font-antialiasing = "grayscale";
            font-hinting = "none";
        };

        "org/gnome/desktop/peripherals/pointingstick" = {
            scroll-method = "none";
        };
    };
}