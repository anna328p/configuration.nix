{ ... }:

{
    boot.initrd = {
        availableKernelModules = [
            "ahci" "nvme" "sd_mod"
            "ehci_pci" "xhci_pci" "usb_storage" "uas"
        ];
    };
}
