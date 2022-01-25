{
    stdenv,
    fetchFromGitHub,
    python3,
    storagePath,
    writeScript,
    bash,
    jq,
    writeText,
    config
}:

let
    python = python3;

    pythonPackages = python.pkgs;

    completeConfig = {
        path = storagePath;
    };

    configFile = writeText "config.json" (builtins.toJSON completeConfig);
in
stdenv.mkDerivation rec {
    pname = "SpriteBot";
    version = "latest";

    src = fetchFromGitHub {
        owner = "PMDCollab";
        repo = "SpriteBot";
        rev = "6c80b0c7a194050a8e893a9c41899acb198a83dc";
        sha256 = "sha256-60GQCzo90jk/Pi7YH3mxhO0fuNHuvgNEPFxbvD9vbrU=";
    };

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
        #${jq}/bin/jq -s '.[0] * .[1]' ${innerConfig} ${configFile} > ${innerConfig}.tmp
        #mv ${innerConfig}.tmp ${innerConfig}
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