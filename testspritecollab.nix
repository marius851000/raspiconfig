{ pkgs ? import <nixpkgs> {}}:

pkgs.callPackage ./spritecollab.nix {
    storagePath = "/NotSpriteCollab";
}