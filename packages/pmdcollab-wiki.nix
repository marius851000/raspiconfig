{ pkgs, node2nix, stdenv, pmdcollab_wiki-src, nodejs, nodePackages, url }:

let
  ifd = stdenv.mkDerivation {
    name = "pmdcollab-wiki-ifd";
    
    src = "${pmdcollab_wiki-src}/app";

    nativeBuildInputs = [ node2nix ];
    
    installPhase = ''
      mkdir $out
      cd $out
      node2nix -l $src/package-lock.json -i $src/package.json
      #for some reason, I can't succed in changing the package.json before node2nix. Something related to purity.
      substituteInPlace node-packages.nix \
        --replace "https://keldaan-ag.github.io/PMD-collab-wiki/" "${url}"
    '';
  };

  customAbout = builtins.toFile "About.tsx" ''
  import Buttons from "./components/buttons";

export default function About(){
    return (
        <div className="App">
            <Buttons/>
            <div className='nes-container' style={{height:'90vh', backgroundColor:'rgba(255,255,255,0.8)', display:'flex', flexFlow:'column', alignItems:'center', justifyContent:'space-evenly'}}>
                <h1 className="nes-text is-primary">The NotSpriteCollab Repository</h1>
                <p>This is a version of SpriteCollab for non-Pokémon or non-canon Pokémon (or other content not accepted here). The condition of use of those elements differ from SpriteCollab. Term of use for a specific Pokémon can be found on <a href="https://hacknews.pmdcollab.org/page:notspritecollab_credit">this page</a>. If some are missing, ask the author.</p>
            </div>
        </div>
      );
}'';

  modules = builtins.trace "${(import (builtins.toPath "${ifd}/default.nix") { inherit pkgs; }).package}" (import (builtins.toPath "${ifd}/default.nix") { inherit pkgs; }).package;
in
  stdenv.mkDerivation {
    name = "pmdcollab-wiki";

    src = modules;

    nativeBuildInputs = [ nodePackages.npm nodejs ];

    buildPhase = ''
      cd lib/node_modules/app

      substituteInPlace package.json \
        --replace "https://keldaan-ag.github.io/PMD-collab-wiki/" "${url}"
      substituteInPlace tsconfig.json \
        --replace "strict\": true" "strict\": false"
      
      substituteInPlace src/types/enum.ts \
        --replace "PMDCollab/SpriteCollab" "marius851000/NotSpriteCollab"
      substituteInPlace src/gen/download-tracker.js \
        --replace "PMDCollab/SpriteCollab" "marius851000/NotSpriteCollab"

      substituteInPlace src/components/discord-button.tsx \
        --replace "https://discord.gg/skytemple" "https://discord.gg/VYNXFfHpuf"

      substituteInPlace src/components/search.tsx \
        --replace "Mewtwo" "Duskako"

      cp ${customAbout} src/About.tsx
      

      export HOME=$(mktemp -d)
      npm run build
    '';

    installPhase = ''
      mv build $out
    '';
  }