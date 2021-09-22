{
    inputs.nixpkgs.url = "nixpkgs";
    inputs.pmdsite = {
        url = "github:marius851000/pmd_hack_weekly";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, pmdsite }: {
        nixosConfigurations.marius-rasberrypi = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
                ./hardware.nix
                ./configuration.nix
                (import ./nixosweekly.nix { inherit pmdsite; })
#                ./autoupdate.nix
#                ./ftp_test.nix
            ];
        };
    };
}
