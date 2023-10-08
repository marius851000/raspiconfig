{ modulesPath, pkgs, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda3"; fsType = "btrfs"; };
  swapDevices = [ { device = "/swapfile"; size = 2048; } ];
  
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "scrogne";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuN+cUqYFhHULFrOK0oOxbd46ffjZGN5Nxh43LkgHgb3jEVPc/D1WaEVZj8emds3Vn3amnvLN+0AvHUszCzWKJEkwNwApBHxdupRSwVM6dFqXFkSpirPWkpdtwfx4IAaHyppmwJSYpqYRd3LHTc8NBvsFemO7x7rJHLRGi8sRsEZxqD5YoVBCGNBxIEg2BzxWcqmrveOK8YAIL2TuLkJWp0k6Q52BESvrd2IsqDDSsu/TdkOlSWQoIqTdupbm94EGMeRyFrpNuxbb0EVHd0f+/r3aXkCDDLr7CV5XO37lFgvEFCWYGhQnK8JjF/FZIABioBaStuc0rbGrxa5J/MUIR marius@lutta'' 
  ];

  
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.2"
  ];

  services.postgresql.package = pkgs.postgresql_15;

  boot.kernelParams = [ "zswap.enabled=1" ];

  networking.interfaces = {
    eno0 = {
      ipv6 = {
        addresses = [
          {
            address = "2001:41d0:e:378::1";
            prefixLength = 128;
          }
        ];
      };
    };
  };

  networking.defaultGateway6 = {
    address = "2001:41d0:000e:03ff:00ff:00ff:00ff:00ff";
    interface = "eno0";
  };

  system.stateVersion = "21.11";
}