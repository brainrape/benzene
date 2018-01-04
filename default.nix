{ pkgs ? import <nixpkgs> {}, ... }:
let
  fuego = pkgs.stdenv.mkDerivation {
    name = "fuego";
    buildInputs = [ pkgs.automake pkgs.autoconf pkgs.boost155 ];
    src = pkgs.fetchsvn {
      url =  https://fuego.svn.sourceforge.net/svnroot/fuego/trunk ;
      rev = 1371;
      sha256 = "0h8p3nxph3y5yyzi28xp874rkq45x8yg3sz68vpa4b4853vq08ri";
    };
    buildPhase = ''
      sed -i 's/boost::TIME_UTC/boost::TIME_UTC_/' go/GoGtpEngine.cpp
      sed -i 's/boost::TIME_UTC/boost::TIME_UTC_/' gtpengine/GtpEngine.cpp
      sed -i 's/mutable SgPointSet/SgPointSet/' smartgame/SgPointSetUtil.h
      sed -i 's/native_file_string/string/' go/GoGtpEngine.cpp
      sed -i 's/\, boost::filesystem::native//' fuegomain/FuegoMain.cpp
      sed -i 's/native_file_string/string/' fuegomain/FuegoMainUtil.cpp

      autoreconf -i
      ./configure --prefix=$out --with-boost-libdir=${pkgs.boost155}/lib --enable-assert=yes
      make
    '';
    installPhase = ''
      mkdir -p $out
      make install
      mkdir -p $out/src/
      cp -r . $out/src/fuego
    '';
  };
  benzene = pkgs.stdenv.mkDerivation {
    name = "benzene";
    src = pkgs.fetchFromGitHub {
      owner = "djh2";
      repo = "benzene";
      rev = "83c8caf82e2b9ebf87c1ece5bb6f7341923c99ba";
      sha256 = "0xagbhgal04asfp5rxd9mx1l422hwqkgb14l3j91240p49536jyg";
    };
    BOOST_LIBDIR = "${pkgs.boost155}/lib";
    FUEGO_ROOT = "${fuego}/src/fuego";
    buildInputs = [ pkgs.automake pkgs.autoconf fuego pkgs.boost155 pkgs.db ];
    buildPhase = ''
      sed -i 's/src\/util\/Makefile/src\/util\/Makefile\nsrc\/wolve\/Makefile/' configure.ac
      sed -i 's/boost::TIME_UTC/boost::TIME_UTC_/' src/wolve/WolveEngine.cpp
      sed -i 's/\$(BOOST_SYSTEM_LIB)/\$\(BOOST_SYSTEM_LIB\) \\\n\$\(BOOST_PROGRAM_OPTIONS_LIB\)/' tools/mergesgf/Makefile.am

      autoreconf -i
      ./configure --with-fuego-root=$FUEGO_ROOT --with-boost-libdir=$BOOST_LIBDIR --enable-assert=yes --prefix=$out
      make
    '';
  };
in benzene
