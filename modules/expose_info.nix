{ lib, config, pkgs, ... }:



let
  cfg = config.marinfra.info;

  removeAttrsOrThrow = set: key:
    if builtins.hasAttr key set then
      builtins.removeAttrs set [ key ]
    else
      builtins.throw "removeAttrsOrThrow: key '${key}' does not exist in the set.";
in
{
  options.marinfra.info = with lib; {
    ygg_address = mkOption {
      type = types.str;
      default = "";
      description = "IPv6 address of this machine on the Yggdrasil network. Empty string if unknown.";
    };
    nebula_address = mkOption {
      type = types.str;
      default = "";
      description = "IPv4 nebula address, if the nebula module is enabled.";
    };
    other_machines = mkOption {
      type = types.attrs;
      default = removeAttrsOrThrow cfg.all_machines cfg.this_machine_key;
      description = "Set of other machines as passed from the flake; typically the machine configuration map.";
    };
    all_machines = mkOption {
      type = types.attrs;
      description = "Like other_machines, but with this machine too";
    };
    this_machine_key = mkOption {
      type = types.str;
      default = "";
      description = "this machine key, as used in machines in the flake.nix";
    };
  };
}
