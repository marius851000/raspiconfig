{ dns }:
{ ... }:

{
  services.nsd = {
    enable = true;
    verbosity = 3;
    interfaces = [ "0.0.0.0" "::" ];
    zones = {
      "hacknews.pmdcollab.org" = {
        data = dns.lib.toString "hacknews.pmdcollab.org" (import ./hacknews.pmdcollab.org.nix { inherit dns; });
      };
      "mariusdavid.fr" = {
        data = dns.lib.toString "mariusdavid.fr" (import ./mariusdavid.fr.nix { inherit dns; });
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}