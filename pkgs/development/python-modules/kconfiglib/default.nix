{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "kconfiglib";
  version = "13.7.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ou6PsGECRCxFllsFlpRPAsKhUX8JL6IIyjB/P9EqCiI=";
  };

  # doesnt work out of the box but might be possible
  doCheck = false;

  meta = with lib; {
    description = "A flexible Python 2/3 Kconfig implementation and library";
    homepage = "https://github.com/ulfalizer/Kconfiglib";
    license = licenses.isc;
    maintainers = with maintainers; [ teto ];
  };
}
