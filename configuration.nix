{ config, pkgs, lib, ... }: 
{

  imports = [
    ./modules/machine-site.nix
  ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  console.keyMap = "fr";
  
  #TODO: cron compression
  environment.systemPackages = [ pkgs.fish pkgs.git pkgs.iotop pkgs.htop pkgs.rclone pkgs.diskonaut pkgs.matrix-synapse-tools.rust-synapse-compress-state ];

  services.journald.extraConfig = "SystemMaxUse=300M";
  services = {
    timesyncd.enable = lib.mkForce true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "without-password";
        PasswordAuthentication = false;
      };
    };
  };

  zramSwap.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuN+cUqYFhHULFrOK0oOxbd46ffjZGN5Nxh43LkgHgb3jEVPc/D1WaEVZj8emds3Vn3amnvLN+0AvHUszCzWKJEkwNwApBHxdupRSwVM6dFqXFkSpirPWkpdtwfx4IAaHyppmwJSYpqYRd3LHTc8NBvsFemO7x7rJHLRGi8sRsEZxqD5YoVBCGNBxIEg2BzxWcqmrveOK8YAIL2TuLkJWp0k6Q52BESvrd2IsqDDSsu/TdkOlSWQoIqTdupbm94EGMeRyFrpNuxbb0EVHd0f+/r3aXkCDDLr7CV5XO37lFgvEFCWYGhQnK8JjF/FZIABioBaStuc0rbGrxa5J/MUIR marius@marius-nixos" 
  ];
  
  # !!! Adding a swap file is optional, but strongly recommended!
  hardware.enableRedistributableFirmware = false;
  
  # Preserve space by sacrificing documentation and history
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.gc.dates = "03:00";
  boot.tmp.cleanOnBoot = true;

  documentation = {
    nixos.enable = false;
    man.enable = false;
    doc.enable = false;
    info.enable = false;
  };

  security.acme = {
    defaults.email = "mariusdavid@laposte.net";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;

    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
  };

  marinfra.machine-site.enable = true;

  networking.firewall.allowedTCPPorts = [ 21 80 443 ];

  services.logind.lidSwitch = "ignore";
}
