{ python3Packages, fetchFromGitHub
, kicad
, imagemagick
, xvfb-run
, xclip
, libxslt
, xdotool
}:

python3Packages.buildPythonApplication rec {
  name = "kiauto";
  version = "2.3.1";
  propagatedBuildInputs = [
    kicad.base
    imagemagick
    xvfb-run
    xdotool
    libxslt
    xclip
    python3Packages.psutil
    python3Packages.xvfbwrapper
  ];
  src = fetchFromGitHub {
    owner = "INTI-CMNB";
    repo = "KiAuto";
    rev = "v${version}";
    hash = "sha256-9Tg8V8uSdDqRukbd3VYFLo2r6Qh9c8p3B8s7ht8JC8g=";
  };
}

