{ pkgs }:

{
  extraRules = ''
    # Steam Controller
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", MODE="0666"
    KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
    KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
    KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"

    # GameCube Controller Adapter
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b672", MODE="0666"

    KERNEL=="tun", GROUP="users", MODE="0666"

    # TI
    ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e001", MODE="0666", GROUP="plugdev"
    ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e003", MODE="0666", GROUP="plugdev"
    ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e004", MODE="0666", GROUP="plugdev"
    ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e008", MODE="0666", GROUP="plugdev"
    ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0451", ATTR{idProduct}=="e012", MODE="0666", GROUP="plugdev"
    KERNEL=="tun", GROUP="users", MODE="0660"

    # ADALM2000
    ACTION=="add", SUBSYSTEM=="usb_device", ATTR{idVendor}=="0456", ATTR{idProduct}=="b672", MODE="0666", group="plugdev"
  '' + builtins.readFile (builtins.fetchurl {
    url = "https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules";
    sha256 = "0whfqh0m3ps7l9w00s8l6yy0jkjkssqnsk2kknm497p21cs43wnm";
  }) + builtins.readFile "${pkgs.ddcutil}/share/ddcutil/data/45-ddcutil-i2c.rules";

  packages = with pkgs; [ gnome.gnome-settings-daemon ];
}
