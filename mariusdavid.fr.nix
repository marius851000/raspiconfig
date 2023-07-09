{ dns }:

let
  ip4 = [ "51.38.185.177" ];
  ip6 = [ "2001:41d0:0305:2100:0000:0000:0000:9331" ];

  ip4scrogne = [ "5.196.70.120" ];
  ip6scrogne = [ "2001:41d0:e:378::1" ];
in
{
  SOA = {
    nameServer = "mariusdavid.fr.";
    adminEmail = "mariusdavid@laposte.net";
    serial = 10022;
  };

  NS = [ "ns1.mariusdavid.fr." "ns2.mariusdavid.fr." ];

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
      p = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDBM4SsSpFkXOWAzd1f4/WmAUugiDN3Waz8i4mqF0vFF10zaGiMIu8rTmQQ3RCI35sSJCyHO9lMRSlh8d639t1WvtMe4qHV/LGi/vJe/XhG5HXZHoqgxBkPVAwWKsfGrUE8OzoHO4Qcramed/8YhnErQmwfNh48jQ87iXGQBpR+9QIDAQAB";
    }
  ];

  # mail._domainkey IN      TXT     ( "v=DKIM1; k=rsa; "
  #        "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDBM4SsSpFkXOWAzd1f4/WmAUugiDN3Waz8i4mqF0vFF10zaGiMIu8rTmQQ3RCI35sSJCyHO9lMRSlh8d639t1WvtMe4qHV/LGi/vJe/XhG5HXZHoqgxBkPVAwWKsfGrUE8OzoHO4Qcramed/8YhnErQmwfNh48jQ87iXGQBpR+9QIDAQAB" )  ; ----- DKIM key mail for mariusdavid.fr

  DMARC = [
    {
      p = "none";
    }
  ];

  A = ip4scrogne;
  AAAA = ip6scrogne;

  subdomains = {
    ns1.A = ip4scrogne;
    ns1.AAAA = ip6scrogne;


    ns2.A = ip4scrogne;
    ns2.AAAA = ip6scrogne;

    cloud.A = ip4scrogne;
    cloud.AAAA = ip6scrogne;

    wakapi.A = ip4;
    wakapi.AAAA = ip6;

    awstats.A = ip4;
    awstats.AAAA = ip6;

    reddit1.A = ip4scrogne;
    reddit1.AAAA = ip6scrogne;

    reddit1.MX = [ {
      exchange = "reddit1.mariusdavid.fr.";
      preference = 10;
    } ];

    reddit2.A = ip4scrogne;
    reddit2.AAAA = ip6scrogne;

    reddit2.MX = [ {
      exchange = "reddit2.mariusdavid.fr.";
      preference = 10;
    } ];

    /*testmastodon.A = ip4;
    testmastodon.AAAA = ip6;

    testmastodonwebdomain.A = ip4;
    testmastodonwebdomain.AAAA = ip6;*/

    mastodon.A = ip4scrogne;
    mastodon.AAAA = ip6scrogne;

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

    roundcube.A = ip4scrogne;
    roundcube.AAAA = ip6scrogne;

    tufyggdrasil.AAAA = [ "b200:deb5:f162:56a0:b1d0:fee:6a44:9980" ];

    tmpboard.A = ip4;
    tmpboard.AAAA = ip6;

    vids.A = ip4scrogne;
    vids.AAAA = ip6scrogne;

    boinc.A = ip4scrogne;
    boinc.AAAA = ip6scrogne;

    dragons.A = ip4scrogne;
    dragons.AAAA = ip6scrogne;

    lemmy.A = ip4scrogne;
    lemmy.AAAA = ip6scrogne;

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
