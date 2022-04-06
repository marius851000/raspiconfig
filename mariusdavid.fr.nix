{ dns }:

let
  ip4 = [ "51.38.185.177" ];
  ip6 = [ "2001:41d0:0305:2100:0000:0000:0000:9331" ];
in
{
  SOA = {
    nameServer = "mariusdavid.fr.";
    adminEmail = "mariusdavid@laposte.net";
    serial = 10001;
  };

  NS = [ "mariusdavid.fr." "hacknews.pmdcollab.org." ];

  MX = [ {
    exchange = "mariusdavid.fr.";
    preference = 10;
  } ];

  TXT = [
    "v=spf1 a:mariusdavid.fr -all"
  ];

  DKIM = [
    {
      selector = "mail";
      p = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCgth/qd5Fln03rE/2VAG5ER3NB+Gj0SiZu6YFIYwxntThDc9TzplruDVCjaqDv3AX6co188kT9tva8h/qJK8dW0/eMm/J9Wd4hDMn60chH3OnDPSzJKb/LaUmbjL4HppUU0MlViL2cDh61pNIbpXs9GHo42UN+S2LIIe/PWGN33QIDAQAB";
    }
  ];

  DMARC = [
    {
      p = "none";
    }
  ];

  A = ip4;
  AAAA = ip6;

  subdomains = {
    wakapi.A = ip4;
    wakapi.AAAA = ip6;

    awstats.A = ip4;
    awstats.AAAA = ip6;

    reddit1.A = ip4;
    reddit1.AAAA = ip6;

    reddit1.MX = [ {
      exchange = "reddit1.mariusdavid.fr.";
      preference = 10;
    } ];

    reddit2.A = ip4;
    reddit2.AAAA = ip6;

    reddit2.MX = [ {
      exchange = "reddit2.mariusdavid.fr.";
      preference = 10;
    } ];
  };
}
