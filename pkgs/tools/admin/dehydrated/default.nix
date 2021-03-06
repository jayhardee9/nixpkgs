{ stdenv, bash, coreutils, curl, diffutils, gawk, gnugrep, gnused, openssl, makeWrapper, fetchFromGitHub }:
let
  pkgName = "dehydrated";
  version = "0.6.2";
in
stdenv.mkDerivation rec {
  name = pkgName + "-" + version;

  src = fetchFromGitHub {
    owner = "lukas2511";
    repo = "dehydrated";
    rev = "v${version}";
    sha256 = "19d4kam0dl6l9wfd0v54w4d085jdgi1ljksnqpjj67d6sm23f2l4";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a dehydrated $out/bin
    wrapProgram "$out/bin/dehydrated" --prefix PATH : "${stdenv.lib.makeBinPath [ openssl coreutils gnused gnugrep diffutils curl gawk ]}"
    '';

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "Letsencrypt/acme client implemented as a shell-script";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ maintainers.pstn ];
  };
}
