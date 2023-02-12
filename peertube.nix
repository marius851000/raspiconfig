{ config, pkgs, lib, ... }:

{
  services.peertube = {
    enable = true;
    database.createLocally = true;
    database.user = "nginx";
    redis.createLocally = true;
    smtp = {
      createLocally = false;
      passwordFile = "/secret-peertube-mail-password-clear.txt";
    };
    user = "nginx"; #to share folder with nginx
    group = "nginx";
    localDomain = "peertube.hacknews.pmdcollab.org";
    enableWebHttps = true;
    listenHttp = 34095;
    listenWeb = 443;
    secrets.secretsFile = "/secret-peertube.txt";
    #dataDirs = [ "/var/lib/peertube-mount" ];
    settings = {
      log = {
        level = "debug";
      };
      admin.email = "peertube@hacknews.pmdcollab.org";
      smtp = {
        tls = true;
        username = "peertube@hacknews.pmdcollab.org";
        hostname = "hacknews.pmdcollab.org";
        from_address = "peertube@hacknews.pmdcollab.org";
      };
    };
  };

  services.nginx =
    let
      backend = "http://127.0.0.1:34095";
    in
    {
      virtualHosts."peertube.hacknews.pmdcollab.org" = {
        root = "/var/lib/peertube/storage";
        enableACME = true;
        forceSSL = true;

        locations = {
          "@api" = {
            extraConfig = ''
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Host            $host;
              proxy_set_header X-Real-IP       $remote_addr;

              client_max_body_size  100k; # default is 1M

              proxy_connect_timeout 10m;
              proxy_send_timeout    10m;
              proxy_read_timeout    10m;
              send_timeout          10m;
            '';
            proxyPass = backend;
          };
          "/" = {
            extraConfig = ''
              try_files /dev/null @api;
            '';
          };
          "= /api/v1/videos/upload-resumable" = {
            extraConfig = ''
               client_max_body_size    0;
               proxy_request_buffering off;

              try_files /dev/null @api;
            '';
          };
          "~ ^/api/v1/videos/(upload|([^/]+/editor/edit))$" = {
            extraConfig = ''
              limit_except POST HEAD { deny all; }

              # This is the maximum upload size, which roughly matches the maximum size of a video file.
              # Note that temporary space is needed equal to the total size of all concurrent uploads.
              # This data gets stored in /var/lib/nginx by default, so you may want to put this directory
              # on a dedicated filesystem.
              client_max_body_size                      12G; # default is 1M
              add_header            X-File-Maximum-Size 8G always; # inform backend of the set value in bytes before mime-encoding (x * 1.4 >= client_max_body_size)

              try_files /dev/null @api;
            '';
          };
          " ~ ^/api/v1/(videos|video-playlists|video-channels|users/me)" = {
            extraConfig = ''
              client_max_body_size                      6M; # default is 1M
              add_header            X-File-Maximum-Size 4M always; # inform backend of the set value in bytes before mime-encoding (x * 1.4 >= client_max_body_size)

              try_files /dev/null @api;
            '';
          };
          "@api_websocket" = {
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   Host            $host;
              proxy_set_header   X-Real-IP       $remote_addr;
              proxy_set_header   Upgrade         $http_upgrade;
              proxy_set_header   Connection      "upgrade";
            '';
            proxyPass = backend;
          };
          "/socket.io" = {
            extraConfig = ''
              try_files /dev/null @api_websocket;
            '';
          };
          "/tracker/socket" = {
            extraConfig = ''
              # Peers send a message to the tracker every 15 minutes
              # Don't close the websocket before then
              proxy_read_timeout 15m; # default is 60s

              try_files /dev/null @api_websocket;
            '';
          };
          #Skipped stuff for thumbnail and some optimisation
          "~ ^/static/(webseed|redundancy|streaming-playlists)/" = {
            extraConfig = ''
              limit_rate_after            5M;

              # Clients usually have 4 simultaneous webseed connections, so the real limit is 3MB/s per client
              set $peertube_limit_rate    800k;

              # Increase rate limit in HLS mode, because we don't have multiple simultaneous connections
              if ($request_uri ~ -fragmented.mp4$) {
                set $peertube_limit_rate  5M;
              }

              # Use this line with nginx >= 1.17.0
              limit_rate $peertube_limit_rate;
              # Or this line if your nginx < 1.17.0
              #set $limit_rate $peertube_limit_rate;

              if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin  '*';
                add_header Access-Control-Allow-Methods 'GET, OPTIONS';
                add_header Access-Control-Allow-Headers 'Range,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
                add_header Access-Control-Max-Age       1728000; # Preflight request can be cached 20 days
                add_header Content-Type                 'text/plain charset=UTF-8';
                add_header Content-Length               0;
                return 204;
              }

              if ($request_method = 'GET') {
                add_header Access-Control-Allow-Origin  '*';
                add_header Access-Control-Allow-Methods 'GET, OPTIONS';
                add_header Access-Control-Allow-Headers 'Range,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';

                # Don't spam access log file with byte range requests
                access_log off;
              }

              # Enabling the sendfile directive eliminates the step of copying the data into the buffer
              # and enables direct copying data from one file descriptor to another.
              sendfile on;
              sendfile_max_chunk 1M; # prevent one fast connection from entirely occupying the worker process. should be > 800k.
              aio threads;

              rewrite ^/static/webseed/(.*)$ /videos/$1 break;
              rewrite ^/static/(.*)$         /$1        break;

              try_files $uri @api;
            '';
          };
        };
      };
    };

  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-12.22.12"
    "erlang-22.3.4.24" # used in CouchDB
  ];
  
  networking.firewall.allowedTCPPorts = [ 1935 ];

  environment.systemPackages = [ pkgs.peertube ];

  #mount the network file system
  systemd.services.peertube-storj = {
    description = "mount the rclone path for peertube";
    wantedBy = [ "peertube.service" ];
    environment = {
      HOME = "/peertube-mount-home";
    };
    serviceConfig = {
      Type = "simple";
      User = "nginx";
      Group = "nginx";
      ExecStart = pkgs.writeScript "start_peertube_storj.sh" ''
        #!${pkgs.stdenv.shell}
        fusermount -u /var/lib/peertube-mount | true
        ${pkgs.rclone}/bin/rclone mount videostorage: /var/lib/peertube-mount -vv --vfs-cache-mode full --dir-cache-time 1h --vfs-cache-max-age 1000h --vfs-read-chunk-size 8M --vfs-read-chunk-size-limit 128M --vfs-cache-max-size 10G --allow-other
      '';
      ExecStop = "fusermount -u /var/lib/peertube-mount";
      Restart = "always";
      RestartSec = "10s";
      Environment = [ "PATH=/run/wrappers/bin:$PATH" ];
    };
  };

  systemd.services.peertube.serviceConfig = {
    RestrictAddressFamilies = lib.mkForce [];
    ProtectSystem = lib.mkForce false;
    ProtectHome = lib.mkForce false;
    PrivateTmp = lib.mkForce false;
    PrivateDevices = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    RestrictNamespaces = lib.mkForce false;
    LockPersonality = lib.mkForce false;
    RemoveIPC = lib.mkForce false;
    PrivateMounts = lib.mkForce false;
  };

  programs.fuse.userAllowOther = true;

  systemd.tmpfiles.rules = [
    "d '/peertube-mount-home' 700 nginx nginx -"
    "d '/var/lib/peertube-mount' 700 nginx nginx -"
  ];
}
