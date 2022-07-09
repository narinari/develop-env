{ mkDerivation
, fetchurl
, automake
, autoconf
, pcsclite
, libarib25
}:

mkDerivation {
  name = "recdvb";
  version = "1.3.3";

  buildInputs = [ autoconf automake pcsclite libarib25 ];

  src = fetchurl {
    url = "https://github.com/qpe/recdvb/archive/refs/tags/v1.3.3.tar.gz";
    sha256 = "fb7c004a7053582c4bef655968a55ec8f79c7a4e175f19ea7408dc5ef521120b";
  };
  configureFlags = [ "--enable-b25" ];

  preConfigure = ''
  ./autogen.sh
  '';

  postBuild = ''
  mkdir -p $out/bin
  '';
}
