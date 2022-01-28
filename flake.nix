{
    inputs.nixpkgs.url = "nixpkgs/release-21.11";
    inputs.naersk = {
        url = "github:nix-community/naersk";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    
    inputs.pmd_hack_archive_server = {
        url = "github:marius851000/hack_archive_server";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.naersk.follows = "naersk";
    };

#    inputs.pmdsite = {
#        url = "github:marius851000/pmd_hack_weekly";
#        inputs.nixpkgs.follows = "nixpkgs";
#    };

    outputs = { self, nixpkgs, pmd_hack_archive_server, naersk }: {
        nixosConfigurations.marius-rasberrypi = nixpkgs.lib.nixosSystem rec {
            system = "aarch64-linux";
            modules = [
                ./hardware.nix
                ./configuration.nix
                ./notspritecollab.nix
                (import ./nixosweekly.nix {inherit pmd_hack_archive_server system; })
#                ./autoupdate.nix
#                ./ftp_test.nix
            ];
        };
    };
}
