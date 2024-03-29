{ dns }:

let
  ip4 = [ "51.38.185.177" ];
  ip6 = [ "2001:41d0:0305:2100:0000:0000:0000:9331" ];

  ip4scrogne = [ "5.196.70.120" ];
  ip6scrogne = [ "2001:41d0:e:378::1" ];
in
{
  SOA = {
    nameServer = "hacknews.pmdcollab.org.";
    adminEmail = "mariusdavid@laposte.net";
    serial = 10004;
  };

  NS = [ "hacknews.pmdcollab.org." ];

  MX = [ {
    exchange = "hacknews.pmdcollab.org.";
    preference = 10;
  } ];

  TXT = [
    "v=spf1 a:hacknews.pmdcollab.org -all"
  ];

  DKIM = [
    {
      selector = "mail";
      p = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCUiGofTsdW1d2J4bZthIpATLJOqaPHHgf35Udk9P1tvAzKHtSf2egfVMbQjk+O+PrB9+uMzdBoXXSxSe9hF6zm2w8RR3vMKt5FdXcyAnI5nYwXlO9uFUnaD/dv4ppg9JE7z8jEqabol2pJt0QlwdWGX9zAIvPel3P2v/C9DjhnPwIDAQAB";
    }
  ];

  DMARC = [
    {
      p = "none";
    }
  ];

  A = ip4scrogne;
  AAAA = ip6scrogne;

  subdomains = {
    peertube.A = ip4;
    peertube.AAAA = ip6;
  };
}
