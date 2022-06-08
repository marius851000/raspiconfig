{ pkgs, ... }:

let
  stateDir = "/var/lib/rustdesk-server";
  server = pkgs.rustPlatform.buildRustPackage rec {
    pname = "rustdesk-server";
    version = "unstable";

    src = pkgs.fetchFromGitHub {
      owner = "rustdesk";
      repo = "rustdesk-server";
      rev = "f6792ddbca1ff5551580a7f49422da7887439c96";
      sha256 = "sha256-rvQQYPibew66mpe30KamvjKr0aZ9cs4jhzqIlhJbqI4=";
    };

    cargoSha256 = "sha256-dq8nF5xfJpY8+7SlmtmFONOv33C/vlgswmSnoxk3KT0=";
  };
in
{
  systemd.services.rustdesk-hbbs = {
    enable = true;
    description = "RustDesk's hbbs";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = stateDir;
      Type = "simple";
      ExecStart = "${server}/bin/hbbs -r mariusdavid.fr";
      Restart = "on-failure";
      RestartSec = 60;
    };
  };
  systemd.services.rustdesk-hbbr = {
    enable = true;
    description = "RustDesk's hbbr";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${server}/bin/hbbr";
      Restart = "on-failure";
      RestartSec = 60;
    };
  };

  systemd.tmpfiles.rules = [
      "d '${stateDir}' 700 root root -"
  ];

  environment.systemPackages = [ server ];

  networking.firewall.allowedTCPPorts = [ 21115 21116 21117 21118 21119 ];
  networking.firewall.allowedUDPPorts = [ 21116 ];
}
