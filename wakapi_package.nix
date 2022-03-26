{ buildGoModule, wakapi_src }:

buildGoModule {
  name = "wakapi";
  src = wakapi_src;
  vendorSha256 = "sha256-a/Djkzke28COb+Hs7ksiY823P7jcKLOCiKC83t1zX0o=";
}