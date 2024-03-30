{ lib, ... }:

{
    dconf.settings = {
        "org/gnome/settings-daemon/plugins/power".idle-dim = true;
    };
}