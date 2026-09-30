{
    stdenv,
    fetchFromGitHub,
    python3,
    storagePath,
    writeScript,
    bash,
    jq,
    writeText,
    fetchpatch,
    src
}:

let
    python = python3;

    pythonPackages = python.pkgs;
in
stdenv.mkDerivation rec {
    pname = "SpriteBot";
    version = "latest";

    inherit src;

    patches = [
        # permit to add new absent profile with less information
        /*(fetchpatch {
            url = "https://github.com/PMDCollab/SpriteBot/pull/10.patch";
            sha256 = "sha256-7TknNj90UXg1Xg4f7rB4XQ71VxWcYevwIqoKUszC8wg=";
        })*/

        ./single_allow.diff


        #./apply_shift_credit_once.diff
        #./fix-crash-size-credits.diff
    ];

    postPatch = ''
      substituteInPlace SpriteBot.py \
        --replace-fail "os.path.dirname(os.path.abspath(__file__))" "\"${storagePath}.private\""
      substituteInPlace commands/AddNode.py \
        --replace-fail "return PermissionLevel.STAFF" "return PermissionLevel.EVERYONE"

      substituteInPlace TrackerUtils.py \
        --replace-fail 'CURRENT_LICENSE = "CC_BY-NC_4"' 'CURRENT_LICENSE = "Unspecified"' \
        --replace-fail 'txt.write("All custom graphics not originating from official PMD games are licensed under Attribution-NonCommercial 4.0 International http://creativecommons.org/licenses/by-nc/4.0/.\n")' 'txt.write("No formal licenses unify those sprites and portraits. License for some of them are detailed at https://hacknews.pmdcollab.org/page:notspritecollab_credit\n")' \
        --replace-fail 'can be found in http://sprites.pmdcollab.org/' 'can be found in https://nsc.pmdcollab.org/'
    '';

    buildInputs = with pythonPackages; [
        discordpy
        python
        pillow
        gitpython
        requests
        requests-oauthlib
        tweepy
        mastodon-py
        psutil
    ];

    nativeBuildInputs = [
        pythonPackages.wrapPython
    ];

    prestartScript = let
        innerFolder = "${storagePath}.private";
        innerConfig = "${innerFolder}/config.json";
    in writeScript "prestart-spritebot" ''
        #!${bash}/bin/bash
        mkdir -p "${innerFolder}"
        #jq can't handle 64 bit unsigned integer right now
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp * $out -r
        chmod +x $out/SpriteBot.py
        #cp LICENSE $out

        makeWrapper ${python}/bin/python3 $out/bin/spritebot \
            --set PYTHONPATH $PYTHONPATH \
            --run ${prestartScript} \
            --add-flags $out/SpriteBot.py
    '';
}
