{ pkgs ? import <nixpkgs> {}
, mkDerivation ? pkgs.stdenv.mkDerivation
} :
with pkgs; rec {
  libarib25 = import ./libarib25.nix { inherit mkDerivation fetchFromGitHub cmake clang pcsclite; };
  recpt1 = import ./recpt1.nix { inherit mkDerivation fetchFromGitHub automake autoconf pcsclite libarib25; };
  # recdvb = import ./recdvb.nix { inherit mkDerivation fetchurl automake autoconf pcsclite libarib25; };
  mirakc = import ./mirakc/default.nix { inherit lib fetchurl rustPlatform; };
  epgstation-scripts = callPackage ./epgstation-scripts/default.nix {};
}
