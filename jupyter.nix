{ pkgs, ... }:

{
  services.jupyter = {
    enable = true;
    port = 7934;
    group = "jupyter";
    user = "jupyter";
    password = "\"argon2:$argon2id$v=19$m=10240,t=10,p=8$P85aa/Ek2WKPRiiMYXDCpg$vVNKsvgJWb/EAsw7z0tiydVvk8OCKRoDq3JG3b15QkU\"";
    notebookConfig = ''
      c.NotebookApp.allow_remote_access = true
      
    '';
  };

  users.users.jupyter.group = "jupyter";
  users.groups.jupyter = {};

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    virtualHosts."jupyter.mariusdavid.fr" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:7934";
        proxyWebsockets = true;
      };
    };
  };
}