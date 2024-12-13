{ pkgs, lib, ... }:

let
  source_for_bot = builtins.fetchGit {
    url = "https://git.sc07.company/marius851000/fediverse-canvas-atlas-2024.git";
    rev = "b7e5cfd104b02ef9804756acdb955071537ab550";
  };
in {
  systemd.timers.canvas_atlas = {
    enable = true;
    timerConfig = {
      OnUnitInactiveSec = "5m";
      OnStartupSec = "2m";
      Unit = "canvas_atlas.service";
    };
    wantedBy = [ "timers.target" ];
  };

  users.users.atlas_builder = {
    group = "atlas_builder";
    isSystemUser = true;
    home = "/var/lib/canvas_atlas_bot";
  };
  
  users.users.nginx.extraGroups = [ "atlas_builder" ];

  users.groups.atlas_builder = { };

  systemd.services.canvas_atlas = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      CacheDirectory = "canvas_atlas";
      ExecStart = pkgs.writeScript "canvas_atlas.sh" ''
        #!${pkgs.stdenv.shell}
        export HOME=$CACHE_DIRECTORY
        export PATH=$PATH:${lib.getBin pkgs.git}/bin
        ${pkgs.nix}/bin/nix build git+https://git.sc07.company/marius851000/fediverse-canvas-atlas-2024.git --refresh --out-link /atlas/web -vvv
      '';
      User = "atlas_builder";
      Group = "atlas_builder";
    };
  };

  systemd.tmpfiles.rules = [
    "d '/atlas' 700 canvas_atlas canvas_atlas -"
  ];

  services.nginx = {
    enable = true;

    virtualHosts."atlas.mariusdavid.fr" = {
      root = "/atlas/web";
      forceSSL = true;
    };
  };

  marinfra.ssl.extraDomain = [ "atlas.mariusdavid.fr" ];

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
        ${lib.getExe pkgs.git} checkout main
        rm -r entries/
        ${lib.getExe pkgs.git} reset --hard HEAD
        ${lib.getExe pkgs.git} pull
        ${lib.getExe (pkgs.python3.withPackages (ps: [ ps.requests ps.jsonschema ps.pygithub ])) } ${source_for_bot}/tools/lemmy_fetcher.py
      '';
      User = "atlas_builder";
      Group = "atlas_builder";
    };
  };
}