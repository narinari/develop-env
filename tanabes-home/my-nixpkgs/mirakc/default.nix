{ lib, fetchurl, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "mirakc";
  version = "1.0.50";

  src = fetchurl {
    url = "https://github.com/mirakc/mirakc/archive/refs/tags/1.0.50.tar.gz";
    sha256 = "sha256-C6AMw5910H+AthZEHbHdUL6VlLWJ3ETiS7fqKvp5qbI=";
  };
  cargoSha256 = "sha256-PK4za2xj7DtzeYAtb8MeUn0weY190Dv/h55KiUYIPO8=";

  meta = with lib; {
    description = "A Mirakurun-compatible PVR backend written in Rust";
    homepage = "https://github.com/mirakc/mirakc";
    license = licenses.mit;
  };
}
