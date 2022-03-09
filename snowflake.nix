{ pkgs, ... }:


{
  systemd.services.snowflake = {
    enable = true;
    description = "Snowflake tor proxy";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.snowflake}/bin/proxy";
      Restart = "on-failure";
      RestartSec = 20;
    };
  };
}
