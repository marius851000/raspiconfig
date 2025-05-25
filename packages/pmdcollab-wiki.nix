{ pkgs, napalm, stdenv, pmdcollab_wiki-src, nodejs_22, nodePackages, url, graphql_endpoint }:

#TODO: set up a proxy to those github URL for privacy reason (and use caching while we're at it)

let
  napalm_inst = pkgs.callPackage napalm {};

  customAbout = builtins.toFile "About.tsx" ''
import {
    Box,
    Link,
    Container
} from "@mui/material"
import { Bar } from "./components/bar"

export default function About(){
    return (
        <Box>
            <Bar />
            <Container
              maxWidth="xl"
              sx={{ backgroundColor: "rgba(255,255,255,.9)", p: 4 }}
            >
                <h1 className="nes-text is-primary">The NotSpriteCollab Repository</h1>
                <p>This is a version of SpriteCollab for non-Pokémon or non-canon Pokémon (or other content not accepted here). The condition of use of those elements differ from SpriteCollab. Term of use for a specific Pokémon can be found on <Link href="https://hacknews.pmdcollab.org/page:notspritecollab_credit">this page</Link>. If some are missing, ask the author.</p>
            </Container>
        </Box>
      );
}'';

  package = napalm_inst.buildPackage "${pmdcollab_wiki-src}" { };
in
  stdenv.mkDerivation {
    name = "pmdcollab-wiki";

    src = builtins.trace "${package}" package;

    nativeBuildInputs = [ nodePackages.npm nodejs_22 ];

    patches = [
      ./nsc-bar-cleanup.diff
    ];

    prePatch = ''
      cd _napalm-install
    '';

    buildPhase = ''
      substituteInPlace package.json \
        --replace-fail "https://sprites.pmdcollab.org/" "${url}"

      substituteInPlace src/types/enum.ts \
        --replace-fail "https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master" "https://nsc.pmdcollab.org/spritecollab" \
        --replace-fail "Pokedex Number" "Index Number"

      substituteInPlace index.html \
        --replace-fail "https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master/portrait/0006/Normal.png" "https://nsc.pmdcollab.org/spritecollab/portrait/0000/Normal.png" \
        --replace-fail "The PMD Sprite Repository archives the great art of many artist making portraits based on Pokémon Mystery Dungeon" "Visualize entries in NotSpriteCollab" \
        --replace-fail "PMD Sprite Repository" "NotSpriteCollab Repository"

      substituteInPlace src/Home.tsx \
        --replace-fail "Free to use <strong><Link href='#/About' className='with-credit'>WITH CREDIT TO THE ARTISTS</Link></strong> for ROMhacks, fangames, etc. Don't use for" "Note that there is no unified license for content on this site. <Link href=\"https://hacknews.pmdcollab.org/page:notspritecollab_credit\">See here</Link> for more details." \
        --replace-fail "commercial projects." "" \
        --replace-fail "Search for a pokemon" "Search for a creature" \
        --replace-fail "pokedex number" "creature index"

      substituteInPlace src/ErrorPage.tsx src/components/bar.tsx \
        --replace-fail "https://discord.gg/skytemple" "https://discord.gg/VYNXFfHpuf"

      #TODO: an artist name
      substituteInPlace src/components/search.tsx \
        --replace-fail "Mewtwo... Emmuffin... 151..." "Duskako... Chocobo... 10..."

      substituteInPlace src/index.tsx \
        --replace-fail "https://spriteserver.pmdcollab.org/graphql" "${graphql_endpoint}"

      substituteInPlace src/components/footer.tsx \
        --replace-fail "https://github.com/PMDCollab/SpriteCollab" "https://github.com/marius851000/NotSpriteCollab"

      cp ${customAbout} src/About.tsx


      export HOME=$(mktemp -d)
      npm run build
    '';

    installPhase = ''
      mv build $out
    '';
    }
