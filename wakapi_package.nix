{ buildGoModule, wakapi_src }:

buildGoModule {
  name = "wakapi";
  src = wakapi_src;
  vendorSha256 = "sha256-KfMzRg0LnwCdP+4fGYBoTPvSIQ7c8QSxkFv7WHwfz6A=";
}