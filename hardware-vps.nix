{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.kernelModules = [ "nvme" ];
  boot.supportedFilesystems = [ "btrfs" "vfat" "ntfs" ];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/sda15";
    fsType = "ext2";
  };

  services.beesd.filesystems.root = {
    spec = "/";
    hashTableSizeMB = 1024;
    verbosity = 7;
  };

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

  networking = {
    domain = "hacknews.pmdcollab.org";
  };

  networking.defaultGateway6 = {
    address = "2001:41d0:305:2100::1";
    interface = "ens3";
  };

  swapDevices = [ { device = "/swapfile"; size = 2048; } ];
}