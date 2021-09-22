{ config, pkgs, lib, ... }: {
  
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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
  services.nixosManual.enable = false;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.gc.dates = "03:00";
  boot.cleanTmpDir = true;

  networking.firewall.allowedTCPPorts = [ 21 80 ];
}
