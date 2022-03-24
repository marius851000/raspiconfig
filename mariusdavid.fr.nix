{ dns }:

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

  A = [ "51.38.185.177" ];
  AAAA = [ "2001:41d0:0305:2100:0000:0000:0000:9331" ];
}
