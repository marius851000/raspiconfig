{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/5195ca234686708d662bc7f3b26f83f7408788b5";
  
  inputs.pmd_hack_archive_server = {
    url = "github:marius851000/hack_archive_server";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  #TODO: maybe upstream
  inputs.spritebot_src = {
    url = "github:PMDCollab/SpriteBot/c90213d3452f1c1022865e6ba058fe00149f67cc";
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

  #TODO: upstream -- and server
  #also, update will break the vendorSha256, but that's not too problematic
  inputs.wakapi_src = {
    url = "github:muety/wakapi"; #TODO: try to update, as it segfault for now
    flake = false;
  };

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
    url = "github:ngi-nix/weblate";
    #url = "/home/marius/weblate";
  };

  outputs = {
    self,
    nixpkgs,
    pmd_hack_archive_server,
    spritebot_src,
    nixos-simple-mailserver,
    dns,
    python-github-archive_src,
    wakapi_src,
    mariussite,
    pmdcollab_wiki-src,
    spritecollab_srv-src,
    retoot-bot-src,
    kodionline,
    weblate
  }: {
    nixosConfigurations.marius-rasberrypi = nixpkgs.lib.nixosSystem rec {
      system = "aarch64-linux";
      modules = [
        ./hardware-raspi.nix
        ./configuration.nix
        #./notspritecollab.nix
        (import ./nixosweekly.nix { inherit pmd_hack_archive_server system; })
        ./synapse.nix
        ./backup.nix
        #                ./autoupdate.nix
        #                ./ftp_test.nix
      ];
    };

    # A cheap baremetal server at OVH with lots of storage
    nixosConfigurations.scrogne = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./hardware-scrogne.nix
        ./configuration.nix
      ];
    };

    nixosConfigurations.otulissa = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [ weblate.overlays.default ];
        }
        ./hardware-vps.nix
        ./configuration.nix
        (import ./nixosweekly.nix { inherit pmd_hack_archive_server system; })
        (import ./notspritecollabviewer.nix { inherit spritecollab_srv-src pmdcollab_wiki-src; })
        ./synapse.nix
        ./backup.nix
        (import ./notspritecollab.nix { inherit spritebot_src; })
        nixos-simple-mailserver.nixosModules.mailserver
        ./mailserver.nix
        (import ./dns.nix { inherit dns; })
        ./peertube.nix
        (import ./mariussite.nix { inherit mariussite; })
        #(import ./wakapi.nix { inherit wakapi_src; })
        ./syncthing.nix
        ./mastodon.nix
        #./rustdesk.nix
        #not important, but nice to have
        ./syncthing_relay.nix
        ./snowflake.nix
        (import ./python-github-archive.nix {
          inherit python-github-archive_src;
        })
        (import ./retoot-bot.nix { inherit retoot-bot-src; })
        #(import ./kodionline.nix { inherit kodionline system; })
        #./jupyter.nix
        ./yggdrasil.nix
        weblate.nixosModules.weblate
        ./weblate.nix
      ];
    };
  };
}
