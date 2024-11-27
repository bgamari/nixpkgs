{ lib
, stdenv
, fetchFromGitHub
, rocmUpdateScript
, cmake
, git
, rocm-cmake
, clr
, gfortran
, roctracer
, hipblas
, tensile
, msgpack
}:

# Can also use cuBLAS
stdenv.mkDerivation (finalAttrs: {
  pname = "hipblaslt";
  version = "6.0.2";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "hipBLASLt";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-ZXiq5e6C7MU0nTpill/jCsjt1y3vwdt2xrrqCA6cCtw=";
  };

  patches = [
    ./0001-dont-vendor-tensile.patch
  ];

  nativeBuildInputs = [
    git
    cmake
    rocm-cmake
    clr
    gfortran
    tensile
  ];

  buildInputs = [
    roctracer
    hipblas
    msgpack
  ];

  cmakeFlags = [
    "-DCMAKE_C_COMPILER=hipcc"
    "-DCMAKE_CXX_COMPILER=hipcc"
    # Manually define CMAKE_INSTALL_<DIR>
    # See: https://github.com/NixOS/nixpkgs/pull/197838
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"

    # Madness to support vendored Tensile
    "-DINSTALLED_TENSILE_PATH=${tensile}"
    "-DTensile_CODE_OBJECT_VERSION=default"
  ];

  passthru.updateScript = rocmUpdateScript {
    name = finalAttrs.pname;
    owner = finalAttrs.src.owner;
    repo = finalAttrs.src.repo;
  };

  meta = with lib; {
    description = "ROCm GEMM library";
    homepage = "https://github.com/ROCm/hipBLASLt";
    license = with licenses; [ mit ];
    maintainers = teams.rocm.members;
    platforms = platforms.linux;
    broken = versions.minor finalAttrs.version != versions.minor stdenv.cc.version || versionAtLeast finalAttrs.version "7.0.0";
  };
})
