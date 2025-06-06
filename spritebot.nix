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
        ./non-privileged-add-spritebot.patch
        #./fix-crash-size-credits.diff
    ];

    buildInputs = with pythonPackages; [
        discordpy
        python
        pillow
        GitPython
        requests
        requests-oauthlib
        tweepy
        mastodon-py
        psutil
    ];

    nativeBuildInputs = [
        pythonPackages.wrapPython
    ];

    postPatch = ''
        substituteInPlace SpriteBot.py \
            --replace "os.path.dirname(os.path.abspath(__file__))" "\"${storagePath}.private\""
    '';

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