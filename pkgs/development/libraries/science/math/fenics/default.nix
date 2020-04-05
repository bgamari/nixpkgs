{ stdenv
, fetchurl
, boost
, cmake
, doxygen
, eigen
, numpy
, pkgconfig
, pytest
, pythonPackages
, six
, sympy
, gtest ? null
, hdf5 ? null
, mpi ? null
, ply ? null
, python ? null
, sphinx ? null
, suitesparse ? null
, vtk ? null
, zlib ? null
, docs ? false
}:

let
  version = "2019.1.0";

  dijitso = pythonPackages.buildPythonPackage {
    pname = "dijitso";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/dijitso/downloads/dijitso-${version}.tar.gz";
      sha256 = "1ncgbr0bn5cvv16f13g722a0ipw6p9y6p4iasxjziwsp8kn5x97a";
    };
    buildInputs = [ numpy six ];
    nativeBuildInputs = [ pytest ];
    preCheck = ''
      export HOME=$PWD
    '';
    checkPhase = ''
      runHook preCheck
      py.test test/
      runHook postCheck
    '';
    meta = {
      description = "Distributed just-in-time shared library building";
      homepage = https://fenicsproject.org/;
      platforms = stdenv.lib.platforms.all;
      license = stdenv.lib.licenses.lgpl3;
    };
  };

  fiat = pythonPackages.buildPythonPackage {
    pname = "fiat";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/fiat/downloads/fiat-${version}.tar.gz";
      sha256 = "1sbi0fbr7w9g9ajr565g3njxrc3qydqjy3334vmz5xg0rd3106il";
    };
    buildInputs = [ numpy six sympy ];
    nativeBuildInputs = [ pytest ];
		doCheck = false;
		doInstallCheck = false;
    checkPhase = ''
      pytest test/unit/
    '';
    meta = {
      description = "Automatic generation of finite element basis functions";
      homepage = https://fenicsproject.org/;
      platforms = stdenv.lib.platforms.all;
      license = stdenv.lib.licenses.lgpl3;
    };
  };

  ufl = pythonPackages.buildPythonPackage {
    pname = "ufl";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/ufl/downloads/ufl-${version}.tar.gz";
      sha256 = "04daxwg4y9c51sdgvwgmlc82nn0fjw7i2vzs15ckdc7dlazmcfi1";
    };
    buildInputs = [ numpy six ];
    nativeBuildInputs = [ pytest ];
    checkPhase = ''
      pytest test/
    '';
    meta = {
      description = "A domain-specific language for finite element variational forms";
      homepage = https://fenicsproject.org/;
      platforms = stdenv.lib.platforms.all;
      license = stdenv.lib.licenses.lgpl3;
    };
  };

  ffc = pythonPackages.buildPythonPackage {
    pname = "ffc";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/ffc/downloads/ffc-${version}.tar.gz";
      sha256 = "1zdg6pziss4va74pd7jjl8sc3ya2gmhpypccmyd8p7c66ji23y2g";
    };
    buildInputs = [ dijitso fiat numpy six sympy ufl ];
    nativeBuildInputs = [ pytest ];
		doCheck = false;
    checkPhase = ''
      export HOME=$PWD
      pytest test/unit/
    '';
    meta = {
      description = "A compiler for finite element variational forms";
      homepage = https://fenicsproject.org/;
      platforms = stdenv.lib.platforms.all;
      license = stdenv.lib.licenses.lgpl3;
    };
  };


in
  stdenv.mkDerivation {
    pname = "dolfin";
    inherit version;
    src = fetchurl {
      url = "https://bitbucket.org/fenics-project/dolfin/downloads/dolfin-${version}.tar.gz";
      sha256 = "0kbyi4x5f6j4zpasch0swh0ch81w2h92rqm1nfp3ydi4a93vky33";
    };
    propagatedBuildInputs = [ dijitso fiat ufl ];
    nativeBuildInputs = [ pythonPackages.setuptools ];
    buildInputs = [
      boost cmake dijitso doxygen eigen ffc fiat gtest hdf5 mpi
      numpy pkgconfig six sphinx suitesparse sympy ufl vtk zlib
    ];
    cmakeFlags = [
      "-DDOLFIN_CXX_FLAGS=-std=c++11"
      "-DDOLFIN_AUTO_DETECT_MPI=OFF"
      ("-DDOLFIN_ENABLE_CHOLMOD=" + (if suitesparse != null then "ON" else "OFF"))
      ("-DDOLFIN_ENABLE_DOCS=" + (if docs then "ON" else "OFF"))
      ("-DDOLFIN_ENABLE_HDF5=" + (if hdf5 != null then "ON" else "OFF"))
      ("-DDOLFIN_ENABLE_MPI=" + (if mpi != null then "ON" else "OFF"))
      "-DDOLFIN_ENABLE_PARMETIS=OFF"
      "-DDOLFIN_ENABLE_PETSC=OFF"
      "-DDOLFIN_ENABLE_SCOTCH=OFF"
      "-DDOLFIN_ENABLE_SLEPC=OFF"
      "-DDOLFIN_ENABLE_TRILINOS=OFF"
      ("-DDOLFIN_ENABLE_UMFPACK=" + (if suitesparse != null then "ON" else "OFF"))
      ("-DDOLFIN_ENABLE_ZLIB=" + (if zlib != null then "ON" else "OFF"))
    ];
    enableParallelBuilding = true;
    checkPhase = ''
      make runtests
    '';
    postInstall = "source $out/share/dolfin/dolfin.conf";
    meta = {
      description = "The FEniCS Problem Solving Environment in Python and C++";
      homepage = https://fenicsproject.org/;
      platforms = stdenv.lib.platforms.unix;
      license = stdenv.lib.licenses.lgpl3;
    };
    passthru = { inherit ffc ufl fiat dijitso; };
  }
