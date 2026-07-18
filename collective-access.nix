{
  config,
  pkgs,
  lib,
  ...
}:

let
  domain = "collection.mariusdavid.fr";

  phpPackage = pkgs.php84;
in
{
  users.groups.collectiveaccess = { };
  users.users.collectiveaccess = {
    isSystemUser = true;
    group = "collectiveaccess";
  };

  marinfra.ssl.extraDomain = [ domain ];

  services.nginx.virtualHosts."${domain}" = {
    #basicAuthFile = "/secret-nginx-auth";
    root = "/collectiveaccess";

    # based on https://github.com/netsensei/ansible-collectiveaccess/blob/master/ansible/roles/nginx/templates/default.tpl
    locations."/ca/" = {
      extraConfig = ''
        try_files $uri $uri/ /ca/index.php?$query_string;
      '';
    };

    locations."/ca/.git" = {
      return = "404";
    };

    locations."~ \\.php$" = {
      extraConfig = ''
        proxy_read_timeout 600s;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:${config.services.phpfpm.pools."collectiveaccess".socket};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include ${pkgs.nginx}/conf/fastcgi_params;
      '';
    };

    locations."/pt/" = {
      extraConfig = ''
        try_files $uri $uri/ /pt/index.php?$query_string;
      '';
    };

    locations."/pt/.git" = {
      return = "404";
    };
  };

  services.phpfpm.pools.collectiveaccess = {
    user = "collectiveaccess";
    phpPackage = phpPackage.buildEnv {
      extensions = { enabled, all }: enabled ++ (with all; [
        imagick
      ]);
    };
    phpEnv = {
      PATH = lib.makeBinPath [ pkgs.bash pkgs.coreutils phpPackage pkgs.wget pkgs.exiftool pkgs.mediainfo pkgs.ffmpeg ];
    };
    phpOptions = ''
      upload_max_filesize = 1024M
      post_max_size = 1024M
    '';

    settings = {
      pm = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
      # for debugging
      /*"memory_limit" = "1024m";
      "upload_max_filesize" = "1024m";
      "post_max_size" = "1024m";
      "display_errors" = "on";*/
      # doesn’t work. Do I need to set their category?
    };
  };

  services.mysql = {
    enable = true;
    ensureDatabases = [ "collectiveaccess" ];
    ensureUsers = [
      {
        name = "collectiveaccess";
        ensurePermissions = {
          "collectiveaccess.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
