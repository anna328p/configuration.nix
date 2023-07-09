{ lib, ... }:

{
    dconf.settings = with lib.hm.gvariant; {
        "org/gnome/settings-daemon/plugins/power".idle-dim = true;
    };
}
