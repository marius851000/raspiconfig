{ buildGoModule, wakapi_src }:

buildGoModule {
  name = "wakapi";
  src = wakapi_src;
  vendorSha256 = "sha256-fKdI8cjZKi7WDWg2mgadSAx7O6hxUYST/3eHXuPkEyA=";
}