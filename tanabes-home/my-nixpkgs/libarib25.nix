{ mkDerivation
, fetchFromGitHub
, cmake
, clang
, pcsclite
}:

mkDerivation {
  name = "libarib25";
  version = "1";

  buildInputs = [ cmake clang pcsclite ];

  src = fetchFromGitHub {
    owner = "stz2012";
    repo = "libarib25";
    rev = "ab6afa7c7f4022af7dda7976489ec7a0716efb9a";
    sha256 = "1jj4qh75rf0awydswrmfsdp3f4vkniyzmwks48ahy0mjvk6y182m";
  };
}
