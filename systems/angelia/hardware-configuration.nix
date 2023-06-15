{ ... }:
{
  boot.loader.grub.device = "/dev/sda";
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
  swapDevices = [
	{ device = "/swapfile"; }
  ];
}
