{
    inputs.nixpkgs.url = "nixpkgs";

    inputs.pmd_hack_archive_server = {
        url = "github:marius851000/hack_archive_server";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    inputs.spritebot_src = {
        url = "github:PMDCollab/SpriteBot";
        flake = false;
    };

    inputs.nixos-simple-mailserver = {
        url = "git+https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git";
    };

    inputs.dns = {
      url = "github:kirelagin/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";  # (optionally)
    };

#    inputs.pmdsite = {
#        url = "github:marius851000/pmd_hack_weekly";
#        inputs.nixpkgs.follows = "nixpkgs";
#    };

    outputs = { self, nixpkgs, pmd_hack_archive_server, spritebot_src, nixos-simple-mailserver, dns }: {
        nixosConfigurations.marius-rasberrypi = nixpkgs.lib.nixosSystem rec {
            system = "aarch64-linux";
            modules = [
                ./hardware-raspi.nix
                ./configuration.nix
                #./notspritecollab.nix
                (import ./nixosweekly.nix {inherit pmd_hack_archive_server system; })
                ./synapse.nix
#                ./autoupdate.nix
#                ./ftp_test.nix
            ];
        };

        nixosConfigurations.marius-vps = nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            modules = [
                ./hardware-vps.nix
                ./configuration.nix
                (import ./nixosweekly.nix {inherit pmd_hack_archive_server system; })
                ./synapse.nix
                (import ./notspritecollab.nix {inherit spritebot_src; })
                nixos-simple-mailserver.nixosModules.mailserver
                ./mailserver.nix
                (import ./dns.nix {inherit dns; })
                ./snowflake.nix
            ];
        };
    };
}
