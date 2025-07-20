{ pkgs, lib, ... }:

let
  source_for_bot = builtins.fetchGit {
    url = "https://sc07.dev/fediverse.events/canvas-atlas.git";
    rev = "89e6c7eb9496ddf2fca006243bb68d81f46025dd";
  };
in {

  users.users.nginx.extraGroups = [ "atlas_builder" ];

  users.groups.atlas_builder = { };

  users.users.atlas_builder = {
    group = "atlas_builder";
    isSystemUser = true;
    home = "/var/lib/canvas_atlas_bot";
  };

  systemd.tmpfiles.rules = [
    "d '/atlas' 700 canvas_atlas canvas_atlas -"
  ];

  services.nginx = {
    enable = true;

    virtualHosts."atlas.mariusdavid.fr" = {
      root = "/atlas/atlas2024/web";
      forceSSL = true;
    };

    virtualHosts."atlas2025.mariusdavid.fr" = {
      root = "/atlas/atlas2025/web";
      forceSSL = true;
    };
  };

  marinfra.ssl.extraDomain = [ "atlas.mariusdavid.fr" "atlas2025.mariusdavid.fr" ];

  systemd.services.canvas_atlas_2024 = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      CacheDirectory = "canvas_atlas";
      ExecStart = pkgs.writeScript "canvas_atlas.sh" ''
        #!${pkgs.stdenv.shell}
        export HOME=$CACHE_DIRECTORY
        export PATH=$PATH:${lib.getBin pkgs.git}/bin
        ${pkgs.nix}/bin/nix build git+https://sc07.dev/fediverse.events/canvas-atlas.git#website2024 --refresh --out-link /atlas/atlas2024 -vvv
      '';
      User = "atlas_builder";
      Group = "atlas_builder";
    };
  };

  systemd.timers.canvas_atlas_2024 = {
    enable = true;
    timerConfig = {
      OnUnitInactiveSec = "5m";
      OnStartupSec = "2m";
      Unit = "canvas_atlas_2024.service";
    };
    wantedBy = [ "timers.target" ];
  };


  systemd.services.canvas_atlas_2025 = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      CacheDirectory = "canvas_atlas";
      ExecStart = pkgs.writeScript "canvas_atlas.sh" ''
        #!${pkgs.stdenv.shell}
        export HOME=$CACHE_DIRECTORY
        export PATH=$PATH:${lib.getBin pkgs.git}/bin
        ${pkgs.nix}/bin/nix build git+https://sc07.dev/fediverse.events/canvas-atlas.git#website2025 --refresh --out-link /atlas/atlas2025 -vvv
      '';
      User = "atlas_builder";
      Group = "atlas_builder";
    };
  };

  systemd.timers.canvas_atlas_2025 = {
    enable = true;
    timerConfig = {
      OnUnitInactiveSec = "5m";
      OnStartupSec = "2m";
      Unit = "canvas_atlas_2025.service";
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.timers.canvas_atlas_bot = {
    enable = true;
    timerConfig = {
      OnUnitInactiveSec = "6m";
      OnStartupSec = "3m";
      Unit = "canvas_atlas_bot.service";
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.services.canvas_atlas_bot = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      StateDirectory="canvas_atlas_bot";
      ExecStart = pkgs.writeScript "canvas_atlas_bot.sh" ''
        #!${pkgs.stdenv.shell}
        set -e
        export PATH=$PATH:${lib.getBin pkgs.git}/bin:${lib.getBin pkgs.openssh}/bin
        source /secret/atlas_bot_config.sh
        cd $STATE_DIRECTORY
        export HOME=$STATE_DIRECTORY
        cd git_repo
        ${lib.getExe pkgs.git} fetch origin
        ${lib.getExe pkgs.git} reset --hard
        ${lib.getExe pkgs.git} checkout main
        rm -rf entries/
        rm -rf entries2025/
        ${lib.getExe pkgs.git} reset --hard origin/main
        ${lib.getExe (pkgs.python3.withPackages (ps: [ ps.requests ps.jsonschema ps.pygithub ps.click ])) } ${source_for_bot}/tools/lemmy_fetcher.py
      '';
      User = "atlas_builder";
      Group = "atlas_builder";
    };
  };
}
