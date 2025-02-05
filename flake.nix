{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  #inputs.nixpkgs.url = "github:marius851000/nixpkgs/fix_lemmy_ui";
  /*inputs.nixpkgs = {
    url = "/home/marius/nixpkgs";
  };*/
  # include https://github.com/NixOS/nixpkgs/pull/264204
  # include https://github.com/NixOS/nixpkgs/pull/265618
  
  inputs.pmd_hack_archive_server = {
    url = "github:marius851000/hack_archive_server";
    #inputs.nixpkgs.follows = "nixpkgs";
  };

  #TODO: maybe upstream
  inputs.spritebot_src = {
    url = "github:PMDCollab/SpriteBot";
    flake = false;
  };

  inputs.nixos-simple-mailserver = {
    url = "git+https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git";
  };

  inputs.dns = {
    url = "github:kirelagin/dns.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.python-github-archive_src = {
    url = "github:josegonzalez/python-github-backup";
    flake = false;
  };

  inputs.pmdcollab_wiki-src = {
    url = "github:marius851000/PMD-collab-wiki/fix_carousel_width";
    flake = false;
  };
  inputs.spritecollab_srv-src = {
    url = "github:PMDCollab/spritecollab-srv";
    flake = false;
  };

  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  inputs.mariussite = {
    url = "github:marius851000/mysite/259a46ccb935c14f113c73f0e5b70883ce69feb7";
    flake = false;
  };
  
  inputs.retoot-bot-src = {
    url = "github:marius851000/mastodon-retoot-bot";
    flake = false;
  };

  inputs.kodionline = {
    url = "github:marius851000/kodionline";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.hacky-account-manager = {
    url = "github:marius851000/hacky-account-manager/c54dbf014ad09be3c3f82e1f1668a16e09c8596c";
  };

  inputs.glitch-soc-package = {
    url = "github:IbzanHyena/glitch-social-nix";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    pmd_hack_archive_server,
    spritebot_src,
    nixos-simple-mailserver,
    dns,
    python-github-archive_src,
    mariussite,
    pmdcollab_wiki-src,
    spritecollab_srv-src,
    retoot-bot-src,
    kodionline,
    hacky-account-manager,
    glitch-soc-package,
    deploy-rs
  }: {
    # A cheap baremetal server at OVH with lots of storage
    nixosConfigurations.scrogne = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./secret.nix
        ./ip_redirect.nix
        ./hardware-configuration/scrogne.nix
        ./configuration.nix
        nixos-simple-mailserver.nixosModules.mailserver
        ./mailserver.nix
        ./backup.nix
        ./syncthing.nix
        ./atlas.nix
        (import ./dns.nix { inherit dns; })
        (import ./mariussite.nix { inherit mariussite; })
        ./wakapi.nix
        ./prometheus.nix
        ./grafana.nix
        (import ./notspritecollab.nix { inherit spritebot_src; })
        (import ./retoot-bot.nix { inherit retoot-bot-src; })
        ./peertube.nix
        (import ./mastodon.nix { inherit glitch-soc-package; })
        ./lemmy.nix
        (import ./notspritecollabviewer.nix { inherit spritecollab_srv-src pmdcollab_wiki-src; })
        ./nextcloud.nix
        (import ./hacky-account-manager.nix { inherit hacky-account-manager system; })
        (import ./nixosweekly.nix { inherit pmd_hack_archive_server system; })
        (import ./hydra.nix { hostname = "hydra-scrogne.mariusdavid.fr"; })
      ];
    };

    deploy.nodes.scrogne = {
      hostname = "scrogne.net.mariusdavid.fr";
      profiles.system = {
        sshUser = "root";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.scrogne;
      };
    };

    # A laptop with broken screen, a GT980, multi core, 8GiB of (LDDR3) RAM and 1TiB of HDD
    nixosConfigurations.marella = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./secret.nix
        ./hardware-configuration/marella.nix
        ./backup.nix
        ./syncthing.nix
        ./nexusback.nix
        ./transmission.nix
        (import ./hydra.nix { hostname = "hydra.mariusdavid.fr"; })
        #TODO: fix compilation

        ./synapse.nix
        ./weblate.nix

        {
          #marinfra.otp.enable = true;

          marinfra.paperless = {
            enable = true;
            domain = "paperless.mariusdavid.fr";
          };

          marinfra.ceph.enable = true;
          marinfra.ceph.mon-mgr.enable = true;
          marinfra.ceph.daemon_name = "marella";
          marinfra.ceph.osd.storages = [ 1 5 ];
          marinfra.ceph.mds.enable = true;

          marinfra.ssl.extraDomain = [ "otp.mariusdavid.fr" "ceph.mariusdavid.fr" ];

          services.nginx = {
            virtualHosts."ceph.mariusdavid.fr" = {
              basicAuthFile = "/secret/nginx-pass-otp";
              locations."/" = {
                proxyPass = "http://localhost:8080/";
              };
            };
          };
          
          services.syncthing.settings.folders.dragons = {
            id = "dragons";
            path = "/dragons";
            devices = [ "mariuspc" ];
            ignorePerms = true;
          };
          systemd.tmpfiles.rules = [
            "d '/dragons' 700 dokuwiki_pool dokuwiki_pool -"
          ];

          #marinfra.kubernetes.enable = true;

          /*services = {
            xserver = {
              enable = true;
              layout = "fr";
              xkbOptions = "eurosign:e";
              libinput.enable = true;
              displayManager.sddm.enable = true;
              desktopManager.plasma5.enable = true;
            };
          };*/
        }
      ];
    };

    deploy.nodes.marella = {
      hostname = "192.168.1.22";
      profiles.system = {
        sshUser = "root";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.marella;
      };
    };

    # a second laptop with a broken screen and only 4GB of RAM
    nixosConfigurations.noctus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./secret.nix
        ./hardware-configuration/noctus.nix
        {
          #marinfra.kubernetes.enable = true;
          #marinfra.kubernetes.master.enable = true;
        }
      ];
    };

    #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
