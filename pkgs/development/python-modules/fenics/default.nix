{ stdenv
, dolfin
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

pythonPackages.buildPythonPackage {
  pname = "fenics";
  inherit (dolfin) version src;
  patches = [
    ./update-pybind11.patch
    ./hardcode-dolfin-pkgconfig.patch
  ];
  postPatch = ''
    cd python
    substituteInPlace dolfin/jit/jit.py --replace 'DOLFIN_PC_PATH' '"${dolfin}/lib/pkgconfig/dolfin.pc"'
  '';
  propagatedBuildInputs = [
    pythonPackages.pkgconfig pythonPackages.setuptools
    dolfin dolfin.ffc dolfin.fiat dolfin.ufl dolfin.dijitso
    six sympy ply python numpy pythonPackages.pybind11
  ];
  buildInputs = [ boost dolfin.ffc ];
  nativeBuildInputs = [ cmake ];
  dontUseCmakeConfigure = true;
  DOLFIN_ENABLE_MPI4PY = false;
  DOLFIN_ENABLE_PETSC4PY = false;
  #doCheck = false;
  meta = {
    description = "The FEniCS Problem Solving Environment in Python and C++";
    homepage = https://fenicsproject.org/;
    platforms = stdenv.lib.platforms.unix;
    license = stdenv.lib.licenses.lgpl3;
  };
}
