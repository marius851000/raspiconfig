{ pkgs, lib, ... }:

{
  services.boinc = {
    enable = true;
    extraEnvPackages = [ pkgs.git ];
  };

  # For the LODA wrapper

  programs.nix-ld.enable = true;

  /*environment.sessionVariables = {
    NIX_LD = pkgs.runCommand "ld.so" {} ''
      ln -s "$(cat '${pkgs.stdenv.cc}/nix-support/dynamic-linker')" $out
    '';
  };*/
}