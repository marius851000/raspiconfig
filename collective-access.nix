{
  config,
  pkgs,
  lib,
  ...
}:

let

in
{
  # Damnit! I had it all configured, but a badly performed rm deleted my non-commited config!

  users.groups.collectiveaccess = { };
  users.users.collectiveaccess = {
    isSystemUser = true;
    group = "collectiveaccess";
  };

  services.phpfpl.pools.collectiveaccess = {
    user = "collectiveaccess";
    phpPackage = pkgs.php82;
    settings = {
      pm = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
      "memory_limit" = "1024m";
      "upload_max_filesize" = "1024m";
      "post_max_size" = "1024m";
      "display_errors" = "on"; # for debugging
    };
  };
}
