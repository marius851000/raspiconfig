{
    inputs.nixpkgs.url = "nixpkgs";
#    inputs.pmdsite = {
#        url = "github:marius851000/pmd_hack_weekly";
#        inputs.nixpkgs.follows = "nixpkgs";
#    };

    outputs = { self, nixpkgs }: {
        nixosConfigurations.marius-rasberrypi = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
                ./hardware.nix
                ./configuration.nix
                ./nixosweekly.nix
#                (import ./nixosweekly.nix { inherit pmdsite; })
#                ./autoupdate.nix
#                ./ftp_test.nix
            ];
        };
    };
}
