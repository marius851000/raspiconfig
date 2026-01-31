{ machines, this_name }:
{ pkgs, lib, ... }:

let
  removeAttrsOrThrow = set: key:
    if builtins.hasAttr key set then
      builtins.removeAttrs set [ key ]
    else
      builtins.throw "removeAttrsOrThrow: key '${key}' does not exist in the set.";
in {

  imports = [
    ./modules/machine-site.nix
    ./modules/ssl.nix
    ./modules/opentripplanner.nix
    ./modules/paperless.nix
    ./modules/yggdrasil.nix
    ./modules/ceph.nix
    ./modules/kubernetes.nix
    ./modules/open_to_trusted.nix
    ./modules/expose_info.nix
    ./modules/extra_hosts.nix
  ];

  marinfra.info = {
    other_machines = removeAttrsOrThrow machines this_name;
    this_machine_key = this_name;
  };
  marinfra.extraHosts.enable = true;


  marinfra.machine-site.enable = true;
  marinfra.yggdrasil.enable = true;
  marinfra.ssl.enable = true;

  marinfra.open_to_trusted.ports = [ "22" "9100" "9558" ]; # some ssh, node exporter, systemd exporter

  nix = {
    #package = pkgs.nixLatest;
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

  environment.systemPackages = [ pkgs.fish pkgs.git pkgs.iotop pkgs.htop pkgs.lsof pkgs.bat pkgs.rclone pkgs.nethogs pkgs.brasero pkgs.vlc pkgs.cdrkit pkgs.dvdbackup pkgs.powertop ];

  services.journald.extraConfig = "SystemMaxUse=300M";
  services = {
    timesyncd.enable = lib.mkForce true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "without-password";
        PasswordAuthentication = false;
        AllowUsers = [ "root" ];
      };
    };
  };

  zramSwap.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuN+cUqYFhHULFrOK0oOxbd46ffjZGN5Nxh43LkgHgb3jEVPc/D1WaEVZj8emds3Vn3amnvLN+0AvHUszCzWKJEkwNwApBHxdupRSwVM6dFqXFkSpirPWkpdtwfx4IAaHyppmwJSYpqYRd3LHTc8NBvsFemO7x7rJHLRGi8sRsEZxqD5YoVBCGNBxIEg2BzxWcqmrveOK8YAIL2TuLkJWp0k6Q52BESvrd2IsqDDSsu/TdkOlSWQoIqTdupbm94EGMeRyFrpNuxbb0EVHd0f+/r3aXkCDDLr7CV5XO37lFgvEFCWYGhQnK8JjF/FZIABioBaStuc0rbGrxa5J/MUIR marius@marius-nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILut+U7dowX6Urm36j9LzIrhwGR22aQThmZOjSR5xgcD marius@nixos-fixe"
  ];

  # !!! Adding a swap file is optional, but strongly recommended!
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Preserve space by sacrificing documentation and history
  /*nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.gc.dates = "03:00";*/

  # That takes a long time to transfer
  nixpkgs.flake.setFlakeRegistry = false;
  nixpkgs.flake.setNixPath = false;

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

  services.prometheus.exporters = {
    node.enable = true;
    systemd.enable = true;
  };

  networking.firewall.allowedTCPPorts = [ 21 80 443 ];

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  systemd.oomd.enableUserSlices = true;
  systemd.oomd.enableRootSlice = true;
  systemd.oomd.enableSystemSlice = true;
}
