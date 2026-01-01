{ dns }:

let
  ip4scrogne = [ "5.196.70.120" ];
  ip6scrogne = [ "2001:41d0:e:378::1" ];

  ip4home = [ "82.66.95.86" ];
  ip6marella = [ "fe80::f279:59ff:fe20:f831" ];
in
{
  SOA = {
    nameServer = "mariusdavid.fr.";
    adminEmail = "mariusdavid@laposte.net";
    serial = 10048;
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

    wakapi.A = ip4scrogne;
    wakapi.AAAA = ip6scrogne;

    hydra-scrogne.A = ip4scrogne;
    hydra-scrogne.AAAA = ip6scrogne;

    awstats.A = ip4scrogne;
    awstats.AAAA = ip6scrogne;

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

    otp.A = ip4scrogne; # actually Marella
    #otp.AAAA = ip6marella;

    paperless.A = ip4scrogne; # actually hosted on Marella
    #paperless.AAAA = ip6marella;

    matrix.A = ip4scrogne; # actually Marella
    #matrix.AAAA = ip6marella;

    archive.A = ip4scrogne; # actually Marella
    #TODO: ipv6

    hydra.A = ip4scrogne; # actually Marella

    ollama.A = ip4scrogne;
    ollama.AAAA = ip6scrogne;

    /*testmastodon.A = ip4;
    testmastodon.AAAA = ip6;

    testmastodonwebdomain.A = ip4;
    testmastodonwebdomain.AAAA = ip6;*/

    mastodon.A = ip4scrogne;
    mastodon.AAAA = ip6scrogne;

    atlas.A = ip4scrogne;
    atlas.AAAA = ip6scrogne;

    atlas2025.A = ip4scrogne;
    atlas2025.AAAA = ip6scrogne;

    /*couchdb.A = ip4;
    couchdb.AAAA = ip6;*/

    #notspriteserver.A = ip4;
    #notspriteserver.AAAA = ip6;

    #notspritecollab.A = ip4;
    #notspritecollab.AAAA = ip6;

    #jupyter.A = ip4;
    #jupyter.AAAA = ip6;

    #kodi.A = ip4scrogne;
    #kodi.AAAA = ip6scrogne;

    translate.A = ip4scrogne; # actually Marella
    translate.AAAA = ip6marella;

    roundcube.A = ip4scrogne;
    roundcube.AAAA = ip6scrogne;

    #tmpboard.A = ip4;
    #tmpboard.AAAA = ip6;

    vids.A = ip4scrogne;
    vids.AAAA = ip6scrogne;

    boinc.A = ip4scrogne;
    boinc.AAAA = ip6scrogne;

    dragons.A = ip4scrogne;
    dragons.AAAA = ip6scrogne;

    lemmy.A = ip4scrogne;
    lemmy.AAAA = ip6scrogne;

    ceph.A = ip4scrogne;

    torrent.A = ip4scrogne;

    rss.A = ip4scrogne;
    rss.AAAA = ip6scrogne;

    univers.A = ip4scrogne;
    univers.AAAA = ip6scrogne;

    nesmy.A = ip4scrogne;
    nesmy.AAAA = ip6scrogne;

    net = {
      subdomains = {
        scrogne = {
          A = ip4scrogne;
          AAAA = ip6scrogne;
        };
        # Currently, marella isn’t publicly routable. I set up HTTP redirect, as it need a domain for SSL
        marella = {
          A = ip4scrogne;
          AAAA = ip6scrogne;
        };
        # blablabla idem
        zana = {
          A = ip4scrogne;
          AAAA = ip6scrogne;
          subdomains = {
            ygg.AAAA = [ "201:4227:d97:c7f2:54bc:b9f4:a4:508c" ];
          };
        };
      };
    };
    /*net = {
      subdomains = {
        otulissa = {
          A = ip4;
          AAAA = ip6;
          subdomains = {
            ygg.AAAA = [ "200:e7e5:8090:9030:15d0:d8d4:8f8f:3ced" ];
          };
        };
      };
    };*/
  };
}
