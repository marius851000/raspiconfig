{ buildGoModule, wakapi_src }:

buildGoModule {
  name = "wakapi";
  src = wakapi_src;
  vendorSha256 = "sha256-h1IZKjSh4Zd/m/HdE4q/RWJKf4RTvROFCF+UqJPbn/w=";
}