{
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/1e03b381e7af7e167cace24b0fc72754e794e40c";
  #inputs.nixpkgs.url = "/home/marius/nixpkgs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/e6123938cafa5f5a368090c68d9012adb980da5f";
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
    inputs.nixpkgs.follows = "nixpkgs"; # (optionally)
  };

  inputs.pypi-deps-db = {
    url = "github:DavHau/pypi-deps-db";
    flake = false;
  };

  inputs.mach-nix = {
    url = "mach-nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.pypi-deps-db.follows = "pypi-deps-db";
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
    url = "github:muety/wakapi/2.3.1";
    flake = false;
  };
  inputs.mariussite = {
    url = "github:marius851000/mysite";
    flake = false;
  };
  #    inputs.pmdsite = {
  #        url = "github:marius851000/pmd_hack_weekly";
  #        inputs.nixpkgs.follows = "nixpkgs";
  #    };

  outputs = {
    self,
    nixpkgs,
    pmd_hack_archive_server,
    spritebot_src,
    nixos-simple-mailserver,
    dns,
    mach-nix,
    python-github-archive_src,
    pypi-deps-db,
    wakapi_src,
    mariussite,
    pmdcollab_wiki-src,
    spritecollab_srv-src
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

    nixosConfigurations.marius-vps = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
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
        (import ./wakapi.nix { inherit wakapi_src; })
        ./syncthing.nix
        ./mastodon.nix
        ./rustdesk.nix
        #not important, but nice to have
        ./syncthing_relay.nix
        ./snowflake.nix
        (import ./python-github-archive.nix {
          inherit mach-nix python-github-archive_src system;
        })
      ];
    };
  };
}
