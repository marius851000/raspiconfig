{ config, pkgs, lib, ... }: {
  
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
  };
  
  environment.systemPackages = [ pkgs.fish pkgs.git pkgs.iotop pkgs.htop pkgs.rclone pkgs.diskonaut ];

  services.journald.extraConfig = "SystemMaxUse=300M";
  services = {
    timesyncd.enable = true;
    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };
  };

  zramSwap.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuN+cUqYFhHULFrOK0oOxbd46ffjZGN5Nxh43LkgHgb3jEVPc/D1WaEVZj8emds3Vn3amnvLN+0AvHUszCzWKJEkwNwApBHxdupRSwVM6dFqXFkSpirPWkpdtwfx4IAaHyppmwJSYpqYRd3LHTc8NBvsFemO7x7rJHLRGi8sRsEZxqD5YoVBCGNBxIEg2BzxWcqmrveOK8YAIL2TuLkJWp0k6Q52BESvrd2IsqDDSsu/TdkOlSWQoIqTdupbm94EGMeRyFrpNuxbb0EVHd0f+/r3aXkCDDLr7CV5XO37lFgvEFCWYGhQnK8JjF/FZIABioBaStuc0rbGrxa5J/MUIR marius@marius-nixos" 
  ];
  
  # !!! Adding a swap file is optional, but strongly recommended!
  #swapDevices = [ { device = "/swapfile"; size = 512; } ];
  hardware.enableRedistributableFirmware = false;
  
  networking = {
    domain = "hacknews.pmdcollab.org";
  };
  
  # Preserve space by sacrificing documentation and history
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  nix.gc.dates = "03:00";
  boot.cleanTmpDir = true;

  documentation = {
    nixos.enable = false;
    man.enable = false;
    doc.enable = false;
    info.enable = false;
  };

  networking.firewall.allowedTCPPorts = [ 21 80 ];
}
