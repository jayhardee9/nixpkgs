{ stdenv
, fetchFromGitHub
, autoreconfHook
, gnutar
, which
, gnugrep
, coreutils
, python
, e2fsprogs
, makeWrapper
, squashfsTools
, gzip
, gnused
, curl
, utillinux
, libarchive
 }:

stdenv.mkDerivation rec {
  name = "singularity-${version}";
  version = "2.5.1";

  enableParallelBuilding = true;

  patches = [ ./env.patch ];

  preConfigure = ''
    sed -i 's/-static//g' src/Makefile.am
    patchShebangs .
  '';

  configureFlags = "--localstatedir=/var";
  installFlags = "CONTAINER_MOUNTDIR=dummy CONTAINER_FINALDIR=dummy CONTAINER_OVERLAY=dummy SESSIONDIR=dummy";

  fixupPhase = ''
    patchShebangs $out
    for f in $out/libexec/singularity/helpers/help.sh $out/libexec/singularity/cli/*.exec $out/libexec/singularity/bootstrap-scripts/*.sh ; do
      chmod a+x $f
      sed -i 's| /sbin/| |g' $f
      sed -i 's| /bin/bash| ${stdenv.shell}|g' $f
      wrapProgram $f --prefix PATH : ${stdenv.lib.makeBinPath buildInputs}
    done
  '';

  src = fetchFromGitHub {
    owner = "singularityware";
    repo = "singularity";
    rev = version;
    sha256 = "1i029qs6dfpyirhbdz0nrx2sh5fddysk4wqkjqj5m60kxs4x8a3d";
  };

  nativeBuildInputs = [ autoreconfHook makeWrapper ];
  buildInputs = [ coreutils gnugrep python e2fsprogs which gnutar squashfsTools gzip gnused curl utillinux libarchive ];

  meta = with stdenv.lib; {
    homepage = http://singularity.lbl.gov/;
    description = "Designed around the notion of extreme mobility of compute and reproducible science, Singularity enables users to have full control of their operating system environment";
    license = "BSD license with 2 modifications";
    platforms = platforms.linux;
    maintainers = [ maintainers.jbedo ];
  };
}
