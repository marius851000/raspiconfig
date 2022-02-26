{
    inputs.nixpkgs.url = "nixpkgs";

    inputs.pmd_hack_archive_server = {
        url = "github:marius851000/hack_archive_server";
        inputs.nixpkgs.follows = "nixpkgs";
    };

#    inputs.pmdsite = {
#        url = "github:marius851000/pmd_hack_weekly";
#        inputs.nixpkgs.follows = "nixpkgs";
#    };

    outputs = { self, nixpkgs, pmd_hack_archive_server }: {
        nixosConfigurations.marius-rasberrypi = nixpkgs.lib.nixosSystem rec {
            system = "aarch64-linux";
            modules = [
                ./hardware-raspi.nix
                ./configuration.nix
                ./notspritecollab.nix
                (import ./nixosweekly.nix {inherit pmd_hack_archive_server system; })
#                ./autoupdate.nix
#                ./ftp_test.nix
            ];
        };

        nixosConfigurations.marius-vps = nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            modules = [
                ./hardware-vps.nix
                ./configuration.nix
                #(import ./nixosweekly.nix {inherit pmd_hack_archive_server system; })
            ];
        };
    };
}
