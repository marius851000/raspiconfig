{
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/0c009e1824a56da4f0ac6284111cf786b4e8af96";
  inputs.nixpkgs.url = "github:marius851000/nixpkgs/temp";
  # include https://github.com/NixOS/nixpkgs/pull/264204
  # include https://github.com/NixOS/nixpkgs/pull/265618
  
  inputs.pmd_hack_archive_server = {
    url = "github:marius851000/hack_archive_server";
    inputs.nixpkgs.follows = "nixpkgs";
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
    url = "github:marius851000/mysite";
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

  inputs.weblate = {
    url = "github:marius851000/weblate/minimal_fixes_for_update";
    inputs.nixpkgs.follows = "nixpkgs";
    #inputs.poetry2nix.url = "github:erictapen/poetry2nix/rpds-py-0.10.3";
    #url = "github:marius851000/weblate/disable_debug";
    #url = "/home/marius/weblate";
  };

  inputs.hacky-account-manager = {
    url = "github:marius851000/hacky-account-manager";
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
    weblate,
    hacky-account-manager,
    glitch-soc-package,
    deploy-rs
  }: {
    # A cheap baremetal server at OVH with lots of storage
    nixosConfigurations.scrogne = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./secret.nix
        ./hardware-configuration/scrogne.nix
        ./configuration.nix
        nixos-simple-mailserver.nixosModules.mailserver
        ./mailserver.nix
        ./backup.nix
        ./syncthing.nix
        (import ./dns.nix { inherit dns; })
        (import ./mariussite.nix { inherit mariussite; })
        ./wakapi.nix
        ./prometheus.nix
        #./yggdrasil.nix
        ./grafana.nix
        (import ./notspritecollab.nix { inherit spritebot_src; })
        (import ./retoot-bot.nix { inherit retoot-bot-src; })
        ./peertube.nix
        (import ./mastodon.nix { inherit glitch-soc-package; })
        ./lemmy.nix
        (import ./notspritecollabviewer.nix { inherit spritecollab_srv-src pmdcollab_wiki-src; })
        ./nextcloud.nix
        #(import ./hacky-account-manager.nix { inherit hacky-account-manager system; })
        (import ./nixosweekly.nix { inherit pmd_hack_archive_server system; })
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

    # A laptop with broken screen, but a GT980, multi core, a broken screen, 8GiB of (LDDR3) RAM and 1TiB of HDD
    nixosConfigurations.marella = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        #./yggdrasil.nix
        ./secret.nix
        ./hardware-configuration/marella.nix
        ./backup.nix
        ./syncthing.nix
        ./nexusback.nix

        {
          nixpkgs.overlays = [ weblate.overlays.default ];
        }
        weblate.nixosModules.weblate
        ./synapse.nix
        ./weblate.nix

        {
          marinfra.otp.enable = true;

          services.syncthing.settings.folders.dragons = {
            id = "dragons";
            path = "/dragons";
            devices = [ "mariuspc" ];
            ignorePerms = true;
          };
          systemd.tmpfiles.rules = [
            "d '/dragons' 700 dokuwiki_pool dokuwiki_pool -"
          ];
        }
      ];
    };

    deploy.nodes.marella = {
      hostname = "192.168.0.210";
      profiles.system = {
        sshUser = "root";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.marella;
      };
    };

    #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}