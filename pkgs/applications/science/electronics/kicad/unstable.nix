{ wxGTK, lib, stdenv, fetchFromGitHub, cmake, mesa, zlib
, libX11, gettext, glew, glm, cairo, curl, openssl, boost, pkgconfig
, doxygen, pcre, libpthreadstubs, libXdmcp

, oceSupport ? true, opencascade_oce
, ngspiceSupport ? true, ngspice
, scriptingSupport ? true, swig, python, wxPython
}:

with lib;
stdenv.mkDerivation rec {
  name = "kicad-unstable-${version}";
  version = "2018-03-02";

  src = fetchFromGitHub {
    owner = "KICad";
    repo = "kicad-source-mirror";
    rev = "3f1a3fe65b5347fa4ac88436730f8fd3a22d8cef";
    sha256 = "1mhs02fmnqg7waa6w3my0czs6jp3xlq16wh2hbk5vpnldf49ggw4";
  };

  postPatch = ''
    substituteInPlace CMakeModules/KiCadVersion.cmake \
      --replace no-vcs-found ${version}
  '';

  # They say they only support installs to /usr or /usr/local,
  # so we have to handle this.
  patchPhase = ''
    sed -i -e 's,/usr/local/kicad,'$out,g common/gestfich.cpp
  '';

  cmakeFlags =
    optionals (oceSupport) [ "-DKICAD_USE_OCE=ON" "-DOCE_DIR=${opencascade_oce}" ]
    ++ optional (ngspiceSupport) "-DKICAD_SPICE=ON"
    ++ optionals (scriptingSupport) [
      "-DKICAD_SCRIPTING=ON"
      "-DKICAD_SCRIPTING_MODULES=ON"
      "-DKICAD_SCRIPTING_WXPYTHON=ON"
      # nix installs wxPython headers in wxPython package, not in wxwidget
      # as assumed. We explicitely set the header location.
      "-DCMAKE_CXX_FLAGS=-I${wxPython}/include/wx-3.0"
    ];

  nativeBuildInputs = [ cmake doxygen  pkgconfig ];
  buildInputs = [
    mesa zlib libX11 wxGTK pcre libXdmcp gettext glew glm libpthreadstubs
    cairo curl openssl boost
  ] ++ optional (oceSupport) opencascade_oce
    ++ optional (ngspiceSupport) ngspice
    ++ optionals (scriptingSupport) [ swig python wxPython ];

  meta = {
    description = "Free Software EDA Suite, Nightly Development Build";
    homepage = http://www.kicad-pcb.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ berce ];
    platforms = with platforms; linux;
  };
}
