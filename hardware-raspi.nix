{ config, pkgs, ... }:

{
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.consoleLogLevel = 7;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [ "elevator=bfq" "gpu_mem=16"];

  nix = {
    daemonIOSchedClass = "idle";
    daemonCPUSchedPolicy = "idle";
  };

  #    boot.kernelParams = ["cma=128M"];
  #    boot.loader.raspberryPi.enable = true;
  #    boot.loader.raspberryPi.version = 3;
  #    boot.loader.raspberryPi.uboot.enable = true;
  #    boot.loader.raspberryPi.firmwareConfig = ''
  #        gpu_mem=128
  #    ''; #switch to 256 if xserver is needed.

  #    boot.kernelPackages = pkgs.linuxPackages_latest;

  #    hardware.deviceTree.filter = "*rpi*.dtb";
  fileSystems = {
    #    "/boot" = {
    #      device = "/dev/disk/by-label/NIXOS_BOOT";
    #      fsType = "vfat";
    #    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  networking.hostName = "marius-rasberrypi";

  fileSystems."/var/lib/postgresql" = {
    device = "/dev/disk/by-uuid/0ff6a670-7aec-4e29-957a-9066007b217f";
    fsType = "btrfs";
  };
}
