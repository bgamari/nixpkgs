{ python3Packages, fetchFromGitHub
, kicad
, poppler_utils
, librsvg
, imagemagick
, kiauto
}:

python3Packages.buildPythonApplication rec {
  name = "kidiff";
  version = "2.5.3";
  propagatedBuildInputs = [
    kicad.base
    imagemagick
    python3Packages.wxPython_4_2
    librsvg
    poppler_utils
    kiauto
  ];
  src = fetchFromGitHub {
    owner = "INTI-CMNB";
    repo = "KiDiff";
    rev = "v${version}";
    hash = "sha256-/CusbneMpRcmE+QJEoONlFrYYWhO2mCGidjNLsn6DRc=";
  };
}
