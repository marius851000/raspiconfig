{ dns }:

{
  SOA = {
    nameServer = "marius851000.fr.eu.org.";
    adminEmail = "mariusdavid@laposte.net";
    serial = 10001;
  };

  NS = [ "marius851000.fr.eu.org." ];

  A = [ "51.38.185.177" ];
  AAAA = [ "2001:41d0:0305:2100:0000:0000:0000:9331" ];
}
