{ hostname }:

{ lib, config, pkgs, ... }:

let
  jq = lib.getExe pkgs.jq;
  curl = lib.getExe pkgs.curl;

  report_status = pkgs.writeScriptBin "report_status" ''
    set -e
    echo "atlas build done"
    cat $HYDRA_JSON
    echo ""
    jobset_name=$(${jq} --raw-output ".jobset" $HYDRA_JSON)
    re='^[0-9]+$'
    if ! [[ $jobset_name =~ $re ]] ; then
      echo "Not a number, likely just not a pr: $jobset_name"
      exit 0
    fi

    buildStatus=$(${jq} --raw-output ".buildStatus" $HYDRA_JSON)
    token=$(cat /secret/hydra_gitlab_token)
    outPath=$(${jq} --raw-output ".outputs[0].path" $HYDRA_JSON)
    echo "outPath: $outPath"
    revision=$(cat $outPath/revision)
    echo "revision: $revision"
    
    buildId=$(${jq} --raw-output ".build" $HYDRA_JSON)
    message=""
    if [[ $buildStatus != 0 ]]; then
      echo "Build failed: $buildStatus"
      message="An error prevented the preview to be built for $revision. More info at https://${hostname}/build/$buildId."
    else
      echo "Build succeeded: $buildStatus"
      message="Preview built for $revision! It can be seen at https://${hostname}/build/$buildId/download/1/. Build details are at https://${hostname}/build/$buildId."
    fi

    ${curl} https://git.sc07.company/api/v4/projects/16/merge_requests/$jobset_name/notes --request POST --header "PRIVATE-TOKEN: $token" --data-urlencode "body=$message"
  '';
in
{
  marinfra.ssl.extraDomain = [ hostname ];

  services.nginx = {
    virtualHosts."${hostname}" = {
      locations."/" = {
        proxyPass = "http://localhost:3010";
      };
    };
  };

  services.hydra = {
    package = pkgs.hydra_unstable.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        # Fix CORS
        (pkgs.fetchpatch {
          url = "https://github.com/NixOS/hydra/pull/1397.patch";
          sha256 = "sha256-u2k1Xhfg733ccBukn+I2L0UArFs/bkOqAu6ZPCW1oRM=";
        })
      ];
    });

    enable = true;
    useSubstitutes = true;
    port = 3010;
    minimumDiskFreeEvaluator = 10;
    minimumDiskFree = 10;
    listenHost = "localhost";
    hydraURL = hostname;
    buildMachinesFiles = [];
    notificationSender = "hydra@mariusdavid.fr";
    extraConfig = ''
      <git-input>
        timeout = 99990
      </git-input>

      <runcommand>
        job = test-atlas:*:*
        command = ${lib.getExe report_status}
      </runcommand>
    '';
  };

  nix.package = pkgs.nixVersions.latest;

  nix.extraOptions = ''
    allowed-uris = https://github.com/ https://gitlab.com github: gitlab: path:/nix/store
  '';

  nix.settings.extra-sandbox-paths = [ /* "/portbuild" "/nexusback" */ ];
}