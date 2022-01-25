{ config, pkgs, lib, ... }: {
  
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    daemonIOSchedClass = "idle";
    #most of the CPU time during building is spend waiting for the microSD card, and this make the website ultra slow
  };
  
  environment.systemPackages = [ pkgs.fish pkgs.git ];
  
  services = {
    timesyncd.enable = true;
    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };
  };
  
  # !!! Adding a swap file is optional, but strongly recommended!
  swapDevices = [ { device = "/swapfile"; size = 512; } ];
  hardware.enableRedistributableFirmware = true;
  
  networking.hostName = "marius-rasberrypi";
  
  # Preserve space by sacrificing documentation and history
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.gc.dates = "03:00";
  boot.cleanTmpDir = true;

  services = {
    nixosManual.enable = false;
    /*ipfs = {
      enableGC = true;
      enable = true;
    };*/
  };

  networking.firewall.allowedTCPPorts = [ 21 80 ];
}
