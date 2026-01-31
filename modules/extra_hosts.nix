{ lib, config, ... }:

let
  cfg = config.marinfra.extraHosts;
in {
  options.marinfra.extraHosts = {
    enable = lib.mkEnableOption "extraHosts";
  };

  config = lib.mkIf cfg.enable {
    networking.extraHosts = ''
      127.0.0.0 ${config.marinfra.info.this_machine_key}.local
      ::1 ${config.marinfra.info.this_machine_key}.local
      ${builtins.concatStringsSep "\n" (
        builtins.map (
          m: "${m.value.options.marinfra.info.ygg_address.value} ${m.name}.local"
        ) (lib.attrsToList config.marinfra.info.other_machines)
      )}
    '';
  };
}
