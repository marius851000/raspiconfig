{ dns }:

let
  ip4 = [ "51.38.185.177" ];
  ip6 = [ "2001:41d0:0305:2100:0000:0000:0000:9331" ];
in
{
  SOA = {
    nameServer = "mariusdavid.fr.";
    adminEmail = "mariusdavid@laposte.net";
    serial = 10009;
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

    /*testmastodon.A = ip4;
    testmastodon.AAAA = ip6;

    testmastodonwebdomain.A = ip4;
    testmastodonwebdomain.AAAA = ip6;*/

    mastodon.A = ip4;
    mastodon.AAAA = ip6;

    /*couchdb.A = ip4;
    couchdb.AAAA = ip6;*/

    notspriteserver.A = ip4;
    notspriteserver.AAAA = ip6;

    notspritecollab.A = ip4;
    notspritecollab.AAAA = ip6;

    jupyter.A = ip4;
    jupyter.AAAA = ip6;

    kodi.A = ip4;
    kodi.AAAA = ip6;

    translate.A = ip4;
    translate.AAAA = ip6;

    roundcube.A = ip4;
    roundcube.AAAA = ip6;

    tufyggdrasil.AAAA = [ "b200:deb5:f162:56a0:b1d0:fee:6a44:9980" ];

    tmpboard.A = ip4;
    tmpboard.AAAA = ip6;

    vids.A = ip4;
    vids.AAAA = ip6;

    net = {
      subdomains = {
        otulissa = {
          A = ip4;
          AAAA = ip6;
          subdomains = {
            ygg.AAAA = [ "200:e7e5:8090:9030:15d0:d8d4:8f8f:3ced" ];
          };
        };
      };
    };
  };
}
