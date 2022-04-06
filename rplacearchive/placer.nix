{ mach-nix, system, pony-pixel_src }:

{ pkgs, ... }:

let
  placer = mach-nix.lib."${system}".mkPython {
    # pname = "PonyPixel";
    # version = "git";
    # src = pony-pixel_src;
    requirements = ''
      requests
      Pillow
      #websocket
      bs4
      numpy
      python-dotenv
      html5lib
      websocket-client
      tqdm
    '';
  };

  package = popplio: pkgs.stdenv.mkDerivation {
    name = "pony-pixel-" + (if popplio then "popplio" else "mlp");

    src = pony-pixel_src;
    #src = ./PonyPixel;

    patchPhase = ''
      rm -rf __pycache__
    '' + (if popplio then
      ''
        #iter 3
        substituteInPlace ./bot.py \
          --replace "rPlaceTemplatesGithubLfs = False" "rPlaceTemplatesGithubLfs = True" \
          --replace "https://media.githubusercontent.com/media/r-ainbowroad/minimap/d/main" "https://hacknews.pmdcollab.org" \
          --replace "\"mlp\"" "\"popplio2\"" \
          --replace "'mlp'" "'popplio2'" \
          --replace "'bot': True, 'mask': True" "'bot': False, 'mask': False"
          #--replace "https://CloudburstSys.github.io/place.conep.one/canvas.png" "https://hacknews.pmdcollab.org/popplio/popplio2-bot.png" \
          #--replace "https://CloudburstSys.github.io/place.conep.one/origin.txt" "https://hacknews.pmdcollab.org/popplio/popplio2-origin.txt"
          #--replace "https://raw.githubusercontent.com/CloudburstSys/place.conep.one/master/canvas.png" "https://hacknews.pmdcollab.org/popplio/popplio2-bot.png" \
          #--replace "https://raw.githubusercontent.com/CloudburstSys/place.conep.one/master/origin.txt" "https://hacknews.pmdcollab.org/popplio/popplio2-origin.txt"
      '' else "");

    installPhase = ''
      mkdir $out
      cp * $out
    '';
  };

  buildService = username: password: popplio: {
      description = "discord bot for ${username} (${password})";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        #StandardOutput = "journal+console";
        Type = "simple";
        ExecStart = "${placer.out}/bin/python -u ${package popplio}/bot.py ${username} ${password}";
        WorkingDirectory = package popplio;
        Restart = "on-failure";
        RestartSec = 65;
      };
    };
in {

  #services.cron = {
  #  enable = true;
  #  systemCronJobs = [
  #    "*/34 * * * *      root    systemctl restart bot1"
  #    "*/34 * * * *      root    systemctl restart bot2"
  #    "*/34 * * * *      root    systemctl restart bot3"
  #    "*/34 * * * *      root    systemctl restart bot4"
  #    "*/34 * * * *      root    systemctl restart bot5"
  #    "*/34 * * * *      root    systemctl restart bot6"
  #    "*/34 * * * *      root    systemctl restart bot7"
  #    "*/34 * * * *      root    systemctl restart bot8"
  #    "*/34 * * * *      root    systemctl restart bot9"
  #    "*/34 * * * *      root    systemctl restart bot10"
  #    "*/34 * * * *      root    systemctl restart bot11"
  #    "*/34 * * * *      root    systemctl restart bot12"
  #    "*/34 * * * *      root    systemctl restart bot13"
  #    "*/34 * * * *      root    systemctl restart bot14"
  #    "*/34 * * * *      root    systemctl restart bot15"
  #    "*/34 * * * *      root    systemctl restart bot16"
  #    "*/34 * * * *      root    systemctl restart bot17"
  #    "*/34 * * * *      root    systemctl restart bot18"
  #  ];
  #};
}
