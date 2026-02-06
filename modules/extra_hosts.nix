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
          m: if m.value.options.marinfra.nebula.enable.value then
            "${m.value.options.marinfra.info.nebula_address.value} ${m.name}.local\n" +
            "${m.value.options.marinfra.info.nebula_address.value} ${m.name}.net.mariusdavid.fr"
          else
            ""
        ) (lib.attrsToList config.marinfra.info.other_machines)
      )}
    '';
  };
}
