{ pkgs, ... }:

{
  systemd.services.transmission_mount = {
    description = "mount the ceph path for transmission";
    wantedBy = [ "transmission.service" ]; #TODO: replace by transmission
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeScript "start_mount_transmission.sh" ''
        #!${pkgs.stdenv.shell}
        ${pkgs.ceph}/bin/ceph-fuse -f --id admin --client_fs=basefs /transmission_files
      '';
      ExecStop = "fusermount -u /transmission_files";
      Restart = "always";
      RestartSec = "10s";
      User = "transmission";
      Environment = [ "PATH=/run/wrappers/bin:$PATH" ];
    };
  };

  programs.fuse.userAllowOther = true;

  services.transmission = {
    enable = true;
    settings = {
      download-dir = "/transmission_files/unreplicated_torrent";
      incomplete-dir-enabled = false;
    };
    #TODO: check if that’s a good idea
    performanceNetParameters = true;
  };

  systemd.services.transmission = {
    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
    };
  };

  marinfra.ssl.extraDomain = [ "torrent.mariusdavid.fr" ];

  services.nginx = {
    virtualHosts."torrent.mariusdavid.fr" = {
      basicAuthFile = "/secret/nginx-pass-otp";
      locations."/" = {
        proxyPass = "http://localhost:9091/";
      };
    };
  };

  environment.systemPackages = [ pkgs.browsh pkgs.firefox ];
}