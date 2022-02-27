{
    stdenv,
    fetchFromGitHub,
    python3,
    storagePath,
    writeScript,
    bash,
    jq,
    writeText,
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

    buildInputs = with pythonPackages; [
        discordpy
        python
        pillow
        GitPython
    ];

    nativeBuildInputs = [
        pythonPackages.wrapPython
    ];

    prePatch = ''
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
        cp *.py $out
        chmod +x $out/SpriteBot.py
        cp LICENSE $out
        
        makeWrapper ${python}/bin/python3 $out/bin/spritebot \
            --set PYTHONPATH $PYTHONPATH \
            --run ${prestartScript} \
            --add-flags $out/SpriteBot.py
    '';
}