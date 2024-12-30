{ lib, ... }:

{
    dconf.settings = {
        "org/gnome/settings-daemon/plugins/power".idle-dim = true;

        "org/gnome/mutter".experimental-features = [
            "scale-monitor-framebuffer"
            "variable-refresh-rate"
        ];
    };
}