{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  #was: vps-b4203bd5
  networking.hostName = "otulissa";

  networking.interfaces = {
    ens3 = {
      ipv6 = {
        addresses = [
          {
            address = "2001:41d0:305:2100::9331";
            prefixLength = 128;
          }
        ];
      };
    };
  };

  networking.defaultGateway6 = {
    address = "2001:41d0:305:2100::1";
    interface = "ens3";
  };
}