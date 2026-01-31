{ lib, config, pkgs, ... }:



let
  cfg = config.marinfra.info;
in
{
  options.marinfra.info = with lib; {
    ygg_address = mkOption {
      type = types.str;
      default = "";
      description = "IPv6 address of this machine on the Yggdrasil network. Empty string if unknown.";
    };
    other_machines = mkOption {
      type = types.attrs;
      default = {};
      description = "Set of other machines as passed from the flake; typically the machine configuration map.";
    };
    this_machine_key = mkOption {
      type = types.str;
      default = "";
      description = "this machine key, as used in machines in the flake.nix";
    };
  };
}
