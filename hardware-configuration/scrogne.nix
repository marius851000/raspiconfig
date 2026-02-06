{ modulesPath, pkgs, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda3";
    fsType = "btrfs";
    options = ["compress=zstd:3" "autodefrag"];
  };
  swapDevices = [ {
    device = "/swapfile";
    size = 2048;
  } ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "scrogne";
  networking.domain = "";


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

  hardware.enableRedistributableFirmware = false; # disable, as it appear unneeded and it take a long time to transfer


  # TODO: move to it’s own module

  /*marinfra.ssl.extraDomain = [ "rss.mariusdavid.fr" ];

  services.freshrss = {
    baseUrl = "https://rss.mariusdavid.fr";
    enable = true;
    virtualHost = "rss.mariusdavid.fr";
    pool = "freshrss";
    defaultUser = "marius";
    passwordFile = "/secret/rsspass.txt";
  };


    services.nginx.virtualHosts."rss.mariusdavid.fr" = {
    basicAuthFile = "/secret-nginx-auth";
    };


  services.phpfpm.pools.freshrss.phpPackage = pkgs.php.buildEnv {
    extensions = ({ enabled, all }: enabled ++ (with all; [
        ctype
    ]));
    };*/

  marinfra.ssl.enable = true;
  marinfra.info.ygg_address = "200:e7e5:8090:9030:15d0:d8d4:8f8f:3ced";
  marinfra.info.nebula_address = "10.100.0.1";
}
